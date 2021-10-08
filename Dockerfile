FROM ubuntu:latest

EXPOSE 6755
EXPOSE 6888

ENV FLAX_ROOT=/root/.flax/mainnet
ENV keys="generate"
ENV harvester="false"
ENV farmer="false"
ENV plots_dir="/plots"
ENV farmer_address="null"
ENV farmer_port="null"
ENV testnet="false"
ENV TZ="Europe/London"

RUN DEBIAN_FRONTEND=noninteractive apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y bc curl lsb-release python3 tar bash ca-certificates git openssl unzip wget python3-pip sudo acl build-essential python3-dev python3.8-venv python3.8-distutils python-is-python3 vim tzdata nano rsync && \
    rm -rf /var/lib/apt/lists/* && \
    ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime && echo "$TZ" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata

ARG BRANCH=latest

RUN echo "Cloning flax-blockchain branch ${BRANCH}"
RUN git clone --branch ${BRANCH} https://github.com/Flax-Network/flax-blockchain.git \
&& cd flax-blockchain \
&& git submodule update --init mozilla-ca \
&& /usr/bin/sh ./install.sh

WORKDIR /farmr
COPY downloadfarmr.sh .
RUN echo "Installing farmr" \
&& /usr/bin/bash downloadfarmr.sh \
&& chmod +x farmr \
&& mv blockchain/xfx.json.template blockchain/xfx.json \
&& mv blockchain/xch.json blockchain/xch.json.template

ENV PATH=/flax-blockchain/venv/bin:$PATH
WORKDIR /flax-blockchain

COPY entrypoint.sh /usr/local/bin/

ENTRYPOINT ["entrypoint.sh"]
