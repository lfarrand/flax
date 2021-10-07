#!/usr/bin/env bash

# shellcheck disable=SC2154
if [[ ${farmer} == 'true' ]]; then
  flax start farmer-only
elif [[ ${harvester} == 'true' ]]; then
  if [[ -z ${farmer_address} || -z ${farmer_port} || -z ${ca} ]]; then
    echo "A farmer peer address, port, and ca path are required."
    exit
  else
    flax configure --set-farmer-peer "${farmer_address}:${farmer_port}"
    flax start harvester
  fi
else
  flax start farmer
fi

./farmr harvester headless > farmr-harvester.log 2>&1 &

trap "flax stop all -d; exit 0" SIGINT SIGTERM

# Ensures the log file actually exists, so we can tail successfully
touch "$FLAX_ROOT/log/debug.log"
tail -f "$FLAX_ROOT/log/debug.log" &
while true; do sleep 1; done
