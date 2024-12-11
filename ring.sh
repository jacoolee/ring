#!/usr/bin/env bash
# set -x

script_file=${BASH_SOURCE[0]}
script_name=$(basename "${script_file}")
script_root=$(cd $(dirname "${script_file}") && pwd)

# debug tool
function alert {
    message="${1}"
    osascript -e "display dialog \"${message}\" buttons {\"OK\"} default button 1"
}

# deeplink format: ring://category/opcode/argument1[/argument2/...]
url="${*}"

# test
alert "${url}"

IFS='/'
read -ra array <<< "${url}"

category="${array[2]}"
rest=("${array[@]:3}")
case $category in
    'rarebook')
        # bash ABSOLUTE_FILE_PATH_TO_YOUR_SCRIPT $rest
        ;;
    *)
        ;;
esac
