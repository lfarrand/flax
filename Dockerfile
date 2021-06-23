FROM ubuntu:latest

EXPOSE 6755
EXPOSE 6888

ENV key_path="null"
ENV keys="generate"
ENV harvester="false"
ENV farmer="false"
ENV plot_dirs="/plots"
ENV farmer_address="null"
ENV farmer_port="null"
ENV testnet="false"
ENV full_node_port="null"

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y curl jq python3 ansible tar bash ca-certificates git openssl unzip wget python3-pip sudo acl build-essential python3-dev python3.8-venv python3.8-distutils apt nfs-common python-is-python3 vim nano

RUN echo "Cloning flax-blockchain"
RUN git clone https://github.com/Flax-Network/flax-blockchain.git --recurse-submodules \
&& cd flax-blockchain \
&& chmod +x install.sh \
&& /usr/bin/sh ./install.sh

WORKDIR /flax-blockchain
RUN mkdir /plots
ADD ./entrypoint.sh entrypoint.sh

ENTRYPOINT ["bash", "./entrypoint.sh"]
