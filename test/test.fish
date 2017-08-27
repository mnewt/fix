#!/usr/local/bin/fish

for f in ./functions/*
  source $f
end

set testing_verbose true

function testing -d 'Run a unit test'
  set description $argv[1]
  set argv $argv[2..-1]
  if test (count $argv) -gt 1
    set value $argv[1]
    set argv $argv[2..-1]
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
      printf "[ OK ][%3d]  %s\n" $code "$description"
    end
  else
    printf "[FAIL][%3d]  %s\n" $code "$description"
    echo "   Program:  $program"
    echo "  Expected:  $value"
    echo "    Result:  $result"
  end
end


testing "Help Print" "fix -h"

set random_number (random)
testing "Print variable in sh syntax" \
        "thing=$random_number" \
        fix -p "export thing=$random_number"

set random_number (random)
testing "Print variable in fish syntax" \
        "set -gx thing \"$random_number\"" \
        fix -f "export thing=$random_number"

testing "Export a variable" "$random_number" echo $thing

set new_random_number (random)
fix "export thing=$random_number"
testing "Modify a variable" "$random_number" echo $thing

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
