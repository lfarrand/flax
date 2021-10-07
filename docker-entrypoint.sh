#!/usr/bin/env bash

# shellcheck disable=SC2154
if [[ -n "${TZ}" ]]; then
  echo "Setting timezone to ${TZ}"
  ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime && echo "$TZ" > /etc/timezone
fi

echo "keys: ${keys}"
echo "ca: ${ca}"
echo "plots_dir: ${plots_dir}"
echo "farmer: ${farmer}"
echo "harvester: ${harvester}"
echo "farmer_address: ${farmer_address}"
echo "farmer_port: ${farmer_port}"
echo "testnet: ${testnet}"
echo "log_level: ${log_level}"

echo "/flax-blockchain/venv/bin/flax" > /farmr/override-xch-binary.txt

cd /flax-blockchain

# shellcheck disable=SC1091
. ./activate

flax init --fix-ssl-permissions

if [[ ${testnet} == 'true' ]]; then
   echo "configure testnet"
   flax configure --testnet true
fi

if [[ ${keys} == "persistent" ]]; then
  echo "Not touching key directories"
elif [[ ${keys} == "generate" ]]; then
  echo "To use your own keys pass them as a text file -v /path/to/keyfile:/path/in/container and -e keys=\"/path/in/container\""
  flax keys generate
elif [[ ${keys} == "copy" ]]; then
  if [[ -z ${ca} ]]; then
    echo "A path to a copy of the farmer peer's ssl/ca required."
  exit
  else
    echo "Found existing farmer ssl keys in "${ca}", using them to initialize"
    flax init -c "${ca}"
  fi
else
  echo "Adding keys from ${keys}"
  flax keys add -f "${keys}"
fi

for p in ${plots_dir//:/ }; do
    mkdir -p "${p}"
    if [[ ! $(ls -A "$p") ]]; then
        echo "Plots directory '${p}' appears to be empty, try mounting a plot directory with the docker -v command"
    fi
    flax plots add -d "${p}"
done

if [[ -n "${log_level}" ]]; then
  flax configure --log-level "${log_level}"
fi

sed -i 's/localhost/127.0.0.1/g' "$FLAX_ROOT/config/config.yaml"

truncate -s 0 /farmrfarmr-harvester.log
truncate -s 0 /farmrlog.txt

exec "$@"
