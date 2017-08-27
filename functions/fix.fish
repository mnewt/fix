#!/usr/bin/env fish

function fix_help
  echo "Fish Shell POSIX Interface: Trick bash utilities into working with fish"
  echo
  echo -n (set_color cyan)'usage:' (set_color normal)'fix [-fhpt] [-s <path_to_shell>] [--] <sh command>'
  echo "
   -f:    Fish    - Print bindings in fish syntax
   -h:    Help    - Print this help message
   -p:    Print   - Print bindings in sh syntax
   -s:    Shell   - Specify a shell interpreter executable path
   -t:    Test    - Print the variables and aliases that would be
                            created, but make no changes
   --:    Optional separator between parameters and shell commands"
end

set -g fix_divider "~-~ FIX DIVIDER ~-~"

function fix_first
  # string join \n -- $argv | sed -n "/$fix_divider/!p;//q"
  for line in $argv
    test "$line" = "$fix_divider"; and break
    echo $line
  end
end

function fix_rest
  # string join \n -- $argv | sed -e "1,/$fix_divider/ d"
  for line in $argv
    set -q print; and echo $line
    test "$line" = "$fix_divider"; and set print
  end
end

set -g fix_parse_statement '^(?:(?:unset|(?:un)?alias|export) )?([a-zA-Z_][a-zA-Z0-9_]*)(?:=(.*))?'

function fix_parse_key
  if not string replace -fr "$fix_parse_statement" '$1' -- "$argv"
    echo fix: error parsing statement: $argv >&2
  end
end

function fix_parse_value
  if not string replace -fr "$fix_parse_statement" '$2' -- "$argv"
    echo fix: error parsing statement: $argv >&2
  end
end


function fix_vars_sh
  set ignore _ OLDPWD PWD SHELLOPTS SHLVL
  set before (fix_first $argv)
  set after (fix_rest $argv)

  # Print variable additions or changes
  for statement in $after
    if not contains -- "$statement" $before
      and not contains -- (fix_parse_key $statement) $ignore
        echo $statement
    end
  end

  # Print unset variables
  for statement in $before
    set key (fix_parse_key $statement)
    if not string match -qr "^$key=" -- $after
      if not contains -- "$key" $ignore
        echo unset $key
      end
    end
  end
end

function fix_vars_fish
  for statement in $argv
    set key (fix_parse_key "$statement")
    if string match -qr '^unset ' -- $statement
      echo "set -e $key"
    else
      set value (fix_parse_value "$statement")

      if test "$key" = 'PATH'
        set value (string replace -a ':' ' ' -- $value)
        echo "set -gx $key $value"
      else
        echo "set -gx $key \"$value\""
      end
    end
  end
end

function fix_alias_sh
  set before (fix_first $argv)
  set after (fix_rest $argv)

  # Print alias additions or changes
  for statement in $after
    not contains -- "$statement" $before; and echo $statement
  end

  # Print unalias'ed aliases
  for statement in $before
    set key (fix_parse_key $statement)
    not string match -qr "^alias $key" -- $after; and echo unalias $key
  end
end

function fix_eval
  for line in $argv
    eval $line
  end
end

function fix_main
  set command $argv
  set previous_vars (eval "$fix_shell -c $fix_var_cmd")
  set previous_alias (eval "$fix_shell -c $fix_alias_cmd")
  set temp_file "/tmp/fix."(random)

  eval "$fix_shell -c \"$command && ($fix_var_cmd && echo $fix_divider && $fix_alias_cmd) >$temp_file\""
  set command_status $status

  if test $command_status -eq 0
    set file_contents (cat $temp_file)
    rm $temp_file

    set new_vars (fix_first $file_contents)
    set vars_sh (fix_vars_sh $previous_vars $fix_divider $new_vars)
    set vars_fish (fix_vars_fish $vars_sh)

    set new_alias (fix_rest $file_contents)
    set alias_sh (fix_alias_sh $previous_alias $fix_divider $new_alias)
    set alias_fish $alias_sh

    if test $fix_print_sh = true
      string join \n -- $vars_sh
      string join \n -- $alias_sh
    end

    if test $fix_print_fish = true
      string join \n -- $vars_fish
      string join \n -- $alias_fish
    end

    if test $fix_test_only != true
      fix_eval $vars_fish
      fix_eval $alias_fish
    end
  else
    echo (set_color red)"Bash command failed:"(set_color normal)" $command"
  end

  return $command_status
end

function fix -d "Run shell scripts, then import variables and aliases modified by them into the fish session"
  set command $argv
  set -g fix_var_cmd env
  set -g fix_alias_cmd alias -p
  set -g fix_print_sh false
  set -g fix_print_fish false
  set -g fix_shell (which bash)
  set -g fix_test_only false

  if test (count $command) -eq 0
    fix_help
    return 0
  end

  set -e next_param
  for opt in $command
    if test $next_param
      set -g $next_param[1] $opt
      set command $command[2..-1]
      set -e param
    else if test "--" = (string sub -s 1 -l 2 -- $opt)
      set command $command[2..-1]
      break
    else if test "-" = (string sub -s 1 -l 1 -- $opt)
      for c in (string split "" -- $opt)[2..-1]
        switch $c
          case p
            set fix_print_sh true
          case f
            set fix_print_fish true
          case h
            fix_help
            return 0
          case s
            set param $param fix_shell
          case t
            set fix_test_only true
          case \*
            echo (set_color red)'error:' (set_color normal)'invalid parameter: ' $param
            fix_help
            return 121
        end
      end
      set command $command[2..-1]
    else
      break # Pass the remainder of the command to bash
    end
  end

  fix_main $command
end
