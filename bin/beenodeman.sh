#!/bin/bash

# beenodeman - main executable
# installs, updates, and manages beenode daemons and wallets

# Copyright (c) 2015-2019 moocowmoo - moocowmoo@masternode.me

# check we're running bash 4 -------------------------------------------------

if [[ ${BASH_VERSION%%.*} != '4' ]];then
    die "beenodeman requires bash version 4. please update. exiting."
fi

# parse any command line switches --------------------------------------------

# --quiet, --verbose don't do anything yet
i=0
until [ "$((i=$i+1))" -gt "$#" ]
do case "$1" in
    --help)    set -- "$@" "-h" ;;
    --quiet)   set -- "$@" "-q" ;;
    --verbose) set -- "$@" "-v" ;;
    --version) set -- "$@" "-V" ;;
    *)         set -- "$@" "$1" ;;
esac; shift; done
OPTIND=1
while getopts "hqvV" o ; do # set $o to the next passed option
  case "$o" in
    q) QUIET=1 ;;
    v) VERBOSE=1 ;;
    V) VERSION=1 ;;
    h) HELP=1 ;;
  esac
done
shift $(($OPTIND - 1))

# load common functions ------------------------------------------------------

BEENODEMAN_BIN=$(readlink -f $0)
BEENODEMAN_GITDIR=$(readlink -f ${BEENODEMAN_BIN%%/bin/${BEENODEMAN_BIN##*/}})
source $BEENODEMAN_GITDIR/lib/beenodeman_functions.sh

# load language packs --------------------------------------------------------

declare -A messages

# set all default strings
source $BEENODEMAN_GITDIR/lang/en_US.sh

# override if configured
lang_type=${LANG%%\.*}
[[ -e $BEENODEMAN_GITDIR/lang/$lang_type.sh ]] && source $BEENODEMAN_GITDIR/lang/$lang_type.sh

# process switch overrides ---------------------------------------------------

# show version and exit if requested
[[ $VERSION || $1 == 'version' ]] && echo $BEENODEMAN_VERSION && exit 0

# show help and exit if requested or no command supplied - TODO make command specific
[[ $HELP || -z $1 ]] && usage && exit 0

# see if users are missing anything critical
_check_dependencies $@

# have command, will travel... -----------------------------------------------

echo -e "${C_CYAN}${messages["beenodeman_version"]} $BEENODEMAN_VERSION$BEENODEMAN_CHECKOUT${C_NORM} - ${C_GREEN}$(date)${C_NORM}"

# do awesome stuff -----------------------------------------------------------
COMMAND=''
case "$1" in
        restart)
            COMMAND=$1
            _find_beenode_directory
            _check_beenoded_state
            # TODO, show uptime: ps --no-header -o pid,etime $(cat $INSTALL_DIR/beenode.pid) | awk '{print $2}'
            case "$2" in
                now)
                    restart_beenoded
                    ;;
                *)
                    echo
                    pending "restart beenoded? "
                    confirm "[${C_GREEN}y${C_NORM}/${C_RED}N${C_NORM}] $C_CYAN" && \
                        restart_beenoded
                    ;;
            esac
            ;;
        update)
            COMMAND=$1
            pending "${messages["gathering_info"]}"
            _check_beenodeman_updates
            _find_beenode_directory
            _get_versions
            _check_beenoded_state
            ok " ${messages["done"]}"
            if [ ! -z "$2" ]; then
                if [ "$2" == '-y' ] || [ "$2" == '-Y' ]; then
                    UNATTENDED=1
                fi

            fi
            if [ ! -z "$ARM" ] && [ $BIGARM -eq 0 ]; then
                die "$COMMAND not supported yet on this platform."
            fi
            update_beenoded
            ;;
        install)
            COMMAND=$1
            pending "${messages["gathering_info"]}"
            _check_beenodeman_updates
            _get_versions
            ok " ${messages["done"]}"
            if [ ! -z "$ARM" ] && [ $BIGARM -eq 0 ]; then
                die "$COMMAND not supported yet on this platform."
            fi
            if [ ! -z "$2" ]; then
                APP=$2;
                if [ "$APP" == 'sentinel' ]; then
                    _find_beenode_directory
                    install_sentinel
                elif [ "$APP" == 'unattended' ]; then
                    UNATTENDED=1
                    install_beenoded
                else
                    echo "don't know how to install: $2"
                fi
                # check command matches:
                # monit
                # beenodeman
                # ???
            else
                install_beenoded
                show_message_configure
            fi
            quit
            ;;
        reinstall)
            COMMAND=$1
            pending "${messages["gathering_info"]}"
            _check_beenodeman_updates
            _find_beenode_directory
            _get_versions
            _check_beenoded_state
            REINSTALL=1
            ok " ${messages["done"]}"
            if [ ! -z "$ARM" ] && [ $BIGARM -eq 0 ]; then
                die "$COMMAND not supported yet on this platform."
            fi
            update_beenoded
            ;;
        sync)
            COMMAND=$1
            cd $BEENODEMAN_GITDIR
            git fetch --prune origin +refs/tags/*:refs/tags/*
            git remote update -p
            if [ -z $(git config user.email) ] ; then
                git config user.email "beenodemanuser"
                git config user.name "beenodemanuser"
            fi
            git stash
            git checkout master
            git reset --hard origin/master

            if [ -e $BEENODEMAN_GITDIR/PREVIOUS_VERSION ]; then
                echo '--------------'
                cat_until "^$( cat $BEENODEMAN_GITDIR/PREVIOUS_VERSION ) " $BEENODEMAN_GITDIR/CHANGELOG.md | sed \
                    -e "/^0\./s/^/$(echo -e $C_YELLOW)/"    -e "/^0\./s/$/$(echo -e $C_NORM)/" \
                    -e "/enh - /s/^/$(echo -e $C_GREEN)/"   -e "/enh - /s/$/$(echo -e $C_NORM)/" \
                    -e "/compat - /s/^/$(echo -e $C_YELLOW)/" -e "/compat - /s/$/$(echo -e $C_YELLOW)/" \
                    -e "/config - /s/^/$(echo -e $C_CYAN)/" -e "/config - /s/$/$(echo -e $C_NORM)/" \
                    -e "/bugfix - /s/^/$(echo -e $C_RED)/"  -e "/bugfix - /s/$/$(echo -e $C_NORM)/"
                echo '--------------'
                rm $BEENODEMAN_GITDIR/PREVIOUS_VERSION
            fi

            if [ ! -z "$2" ]; then
                self=${0##*/};
                shift;
                exec $BEENODEMAN_GITDIR/$self $@
            fi
            quit "${messages["quit_uptodate"]}"
            ;;
        branch)
            COMMAND=$1
            cd $BEENODEMAN_GITDIR
            git fetch --prune origin +refs/tags/*:refs/tags/*
            git remote update -p
            if [ -z $(git config user.email) ] ; then
                git config user.email "beenodemanuser"
                git config user.name "beenodemanuser"
            fi
            BRANCH_OK=$(git for-each-ref --format='%(refname)' refs/remotes/origin | sed -e 's|refs/remotes/origin/||g' | grep "^${2}\$" | wc -l)
            if [ $BRANCH_OK -gt 0 ];then
                git stash
                pending "Switching to git branch "; ok $2
                git checkout $2
                git reset --hard origin/$2
            else
                die "git branch '$2' not found. Exiting."
            fi
            ;;
        vote)
            COMMAND=$1
            pending "${messages["gathering_info"]}"
            _check_beenodeman_updates
            _find_beenode_directory
            _get_versions
            _check_beenoded_state
            ok " ${messages["done"]}"
            echo
            export BEENODE_CLI BEENODEMAN_PID=$$
            /usr/bin/env python $BEENODEMAN_GITDIR/bin/beenodevote.py
            quit 'Exiting.'
            ;;
        status)
            COMMAND=$1
            pending "${messages["gathering_info"]}"
            _check_beenodeman_updates
            _find_beenode_directory
            _get_versions
            _check_beenoded_state
            get_beenoded_status
            get_host_status
            ok " ${messages["done"]}"
            echo
            print_status
            quit 'Exiting.'
            ;;
        *)
            usage
            ;;
esac

quit
