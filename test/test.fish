#!/usr/local/bin/fish

for f in ./functions/*
  source $f
end

set testing_verbose true
set testing_summary_success 0
set testing_summary_failure 0

function print_result -d 'Print the result of a test'
  set -l code $argv[1]
  set -e argv[1]

  printf "["
  switch $code
    case 0
      printf (set_color green)" OK "(set_color normal)
    case '*'
      printf (set_color red)"FAIL"(set_color normal)
  end
  printf "][%3d]  %s\n" $code "$argv"
end

# testing: Run a unit test
# $1:          A text description
# $2:          The expected result of the command
# argv[3..-1]: The command to invoke
function testing -d 'Run a unit test'
  set description $argv[1]
  set -e argv[1]
  if test (count $argv) -gt 1
    set value $argv[1]
    set -e argv[1]
  end
  set program $argv

  set result (eval $program)
  set code $status

  if test $code = 0
     and begin
       test -z "$value"
       or test "$value" = "$result"
     end
    if test $testing_verbose = true
      print_result $code $description
    end
    set testing_summary_success (math $testing_summary_success + 1)
  else
    test $code -eq 0; and set code 1
    print_result $code $description
    echo "   Program:  $program"
    echo "  Expected:  $value"
    echo "    Result:  $result"
    set testing_summary_failure (math $testing_summary_failure + 1)
  end
end

function testing_summary -d 'Print a summary'
  if test $testing_verbose
    echo
    echo Testing Summary
    echo ===============
    echo success: $testing_summary_success
    echo failure: $testing_summary_failure
  end
end

testing "Help Print" "fix -h"

set random_number (random)
testing "Print variable in sh syntax" \
        "thing=\"$random_number\"" \
        fix -p "export thing=$random_number"

set random_number (random)
testing "Print variable in fish syntax" \
        "set -gx thing \"$random_number\"" \
        fix -f "export thing=$random_number"

testing "Export a variable" "$random_number" echo $thing

set new_random_number (random)
fix "export thing=$random_number"
testing "Modify a variable" "$random_number" echo $thing

testing "Print a variable with spaces in its value" \
        "thing=\"$random_number $random_number\"" \
        fix -pt "export thing=\'$random_number $random_number\'"

# TODO: Make newlines not explode
# fix 'export thing="line one
# line two"'
# testing "Variable with newline" \
#         'line one
#         line two' \
#                 echo $thing

testing "Print alias in sh syntax" \
        "alias hello='echo Hello'" \
        fix -p "alias hello=\'echo Hello\'"

testing "Set an alias" "Hello World!" hello World!

testing "Print unset variable in sh syntax" \
        "unset thing" \
        fix -p "unset thing"

fix export thing=1
testing "Print unset variable in fish syntax" \
        "set -e thing" \
        fix -f "unset thing"

testing "Unset a variable" "not set -q thing"

testing "Modify PATH variable" \
        "PATH=\"/one/path:/two/path with spaces:three\"" \
        fix -pt 'export PATH=\"/one/path:/two/path with spaces:three\"'

testing_summary
