#!/usr/bin/env bash
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
SESSION=$1

if [ ! -f ${SCRIPT_DIR}/${SESSION}.sh ]; then
  echo "${SCRIPT_DIR}/${SESSION}.sh does not exist to load session"
  exit 1
else
  source ${SCRIPT_DIR}/${SESSION}.sh
fi

start_session()
{
  if [[ ${SESSION} == "docker" ]] || [[ ${SESSION} == "lead" ]]; then
    tmux new-session -d -s "${SESSION}" -n "${WINDOW}" "ssh docker-${WINDOW}"
  else
    tmux new-session -d -s "${SESSION}" -n ${WINDOW}
  fi
}

add_windows()
{
  INDEX=0
  for WINDOW in "${windows[@]}"
  do
    if [[ ${INDEX} == 0 ]]; then
      start_session
    else
      if [[ ${SESSION} == "docker" ]] || [[ ${SESSION} == "lead" ]]; then
        tmux new-window -n "${WINDOW}" -t "${SESSION}:${INDEX}" "ssh docker-${WINDOW}"
      else
        tmux new-window -n "${WINDOW}" -t "${SESSION}:${INDEX}"
      fi
    fi
    INDEX=$((INDEX+1))
  done
}

check_session()
{
  if ! $(tmux has-session -t ${SESSION}); then
    ssh-add
    add_windows
  fi
  attach_session
}

attach_session()
{
  tmux attach-session -t ${SESSION}
}
eval "$(ssh-agent -s)"
check_session
