#!/usr/bin/env zsh

function _tms-operation() {
  answer=$(_tms-operation-list | fzf-tmux --ansi --prompt="tms >" )
  case $answer in
    *select\ session* ) tmux switch-client -t $(echo  "$answer" | awk '{print $5}' | sed "s/://g") ;;
    *attach*          ) tmux attach -t $(echo "$answer" | awk '{print $4}' | sed 's/://') ;;
    *create*          ) tmux new-session
  esac
}

function _tms-operation-list() {
  if [ -z $TMUX ]; then
    tmux list-sessions 2>/dev/null | while read line; do
      [[ ! "$line" =~ "attached" ]] || line="${GREEN}$line${DEFAULT}"
      echo -e "${GREEN}attach${DEFAULT} ==> [ "$line" ]"
    done
    echo -e "${GREEN}create${DEFAULT} ==> [ ${BLUE}new session${DEFAULT} ]"
  else
    tmux list-sessions 2>/dev/null | while read line; do
      if [[ "$line" =~ "attached" ]]; then
        echo -e "${GREEN}select session${DEFAULT} ==> [ $(echo $line | awk '{print $1 " " $2 " " $3} ') (attached) ]"
      else
        echo -e "${GREEN}select session${DEFAULT} ==> [ $(echo $line | awk '{print $1 " " $2 " " $3} ') ]"
      fi
    done
  fi
}

function _tms-set-color() {
  if [[ "${filter[@]}" =~ "fzf" ]]; then
    readonly BLACK="\033[30m"
    readonly RED="\033[31m"
    readonly GREEN="\033[32m"
    readonly YELLOW="\033[33m"
    readonly BLUE="\033[34m"
    readonly MAGENTA="\033[35m"
    readonly CYAN="\033[36m"
    readonly WHITE="\033[37m"
    readonly BOLD="\033[1m"
    readonly DEFAULT="\033[m"
  fi
}

function main() {
  _tms-set-color
  if [[ $# = 0 ]]; then
    _tms-operation
  elif [[ $# = 1 ]] || [[ $# = 2 ]]; then
    case $1 in
      * ) echo "tms: illegal option $1" 1>&2 && exit 1 ;;
    esac
  else
    echo "tms: option must be one" 1>&2 && exit 1
  fi
}

function tms() {
  main $@
}

zle -N tms
