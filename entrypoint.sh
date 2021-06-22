cd /flax-blockchain

. ./activate

echo "key_path: ${key_path}"
echo "keys: ${keys}"
echo "plot_dirs: ${plot_dirs}"
echo "farmer: ${farmer}"
echo "harvester: ${harvester}"
echo "farmer_address: ${farmer_address}"
echo "farmer_port: ${farmer_port}"
echo "testnet: ${testnet}"

echo "Running flax init"
flax init

if [[ ! -z ${key_path} ]]; then
  echo "Importing keys from ${key_path}"
  flax init -c ${key_path}
else
  if [[ ${keys} == "generate" ]]; then
    echo "Generating keys"
    echo "To use your own keys pass them as a text file -v /path/to/keyfile:/path/in/container and -e keys=\"/path/in/container\""
    flax keys generate
  else
    echo "Adding keys"
    flax keys add -f ${keys}
  fi
fi

if [[ ! "$(ls -A /plots)" ]]; then
  echo "Plots directory appears to be empty and you have not specified another, try mounting a plot directory with the docker -v command "
fi

echo "Adding plot directories ${plot_dirs}"
IFS=';' read -ra ADDR <<< "${plot_dirs}"
for plot_dir in "${ADDR[@]}"; do
  echo "Adding plot directory $plot_dir"
  flax plots add -d $plot_dir
done

sed -i 's/localhost/127.0.0.1/g' ~/.flax/mainnet/config/config.yaml
sed -i 's/log_level: WARNING/log_level: INFO/g' ~/.flax/mainnet/config/config.yaml

if [[ ${farmer} == 'true' ]]; then
  echo "Starting farmer only"
  flax start farmer-only
elif [[ ${harvester} == 'true' ]]; then
  if [[ -z ${farmer_address} || -z ${farmer_port} ]]; then
    echo "A farmer peer address and port are required."
    exit
  else
    echo "Setting farmer peer to ${farmer_address}:${farmer_port}"
    flax configure --set-farmer-peer ${farmer_address}:${farmer_port}
    echo "Starting harvester"
    flax start harvester
  fi
else
  flax start farmer
fi

if [[ ${testnet} == "true" ]]; then
  if [[ -z $full_node_port || $full_node_port == "null" ]]; then
    flax configure --set-fullnode-port 58444
  else
    flax configure --set-fullnode-port ${var.full_node_port}
  fi
fi

while true; do sleep 30; done;
