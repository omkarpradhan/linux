#!/bin/bash
SET_TEXT_SCALING_FACTOR=1
TEXT_SCALING_FACTOR=1.5

# functions

# print script usage
usage() {
    echo ""
    echo "-------------------------------"
    echo "Usage: `basename $0` [OPTIONS]"
    echo "OPTIONS:"
    echo "-h, --help    Display this help message"
    echo "-s, --scale   gnome text scaling"
}

# check for arguments following flag
has_arg() {
    [[ -z "$2" || "$2" == -* ]];
}

# extract arguments
extract_arg() {
    echo "${2}"
}

# take appropriate action
take_action() {
    action=$1
    val=$2
    # echo "Action=$action"
    # echo "val=$val"
    case "${action}" in
        ${SET_TEXT_SCALING_FACTOR})
        echo "Setting GNOME text scaling"
        # read current setting
        echo "Current setting: `dconf read /org/gnome/desktop/interface/text-scaling-factor`"
        # change setting
        dconf write /org/gnome/desktop/interface/text-scaling-factor $val
        # read back
        echo "New setting: `dconf read /org/gnome/desktop/interface/text-scaling-factor`"

    esac
}

parse_command() {
    while [ $# -gt 0 ]
    do
        case "${1}" in
            -h | --help)
                usage
                exit 0
                ;;
            # text scaling
            -s | --scaling)
                if  has_arg $@; then
                    echo "SYNTAX ERROR:Scaling not specified." >&2
                    usage
                    exit 1
                fi
                extract_arg $@
                val=$2
                action=$SET_TEXT_SCALING_FACTOR
                shift
                ;;    
            #default case
            *)
                echo "SYNTAX ERROR:Invalid option \"$1\"" >&2
                usage
                exit 1
                ;;
        esac
        # 2nd shift
        shift
        take_action $action $val    
    done
}

if [ $# -eq 0 ]
then
    usage;
    exit 0;
fi


# main
parse_command "$@"