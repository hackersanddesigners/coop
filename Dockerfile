FROM ubuntu:latest
MAINTAINER JBG <jbg@hackersanddesigners.nl>

RUN apt-get update; \
  apt-get --yes install software-properties-common git curl nginx; \
  add-apt-repository -y ppa:ethereum/ethereum; \
  apt-get update; \
  apt-get --yes install ethereum solc;

ADD gethpass /root
ADD hdcoop.json /root
ADD run.sh /root
ADD coop.sol /root
ADD deploy.js /root

RUN chmod +x /root/run.sh

WORKDIR /root

# Compile contract - JBG
RUN solc -o target --bin --abi coop.sol

# Create geth account and update necessary files, deploy the contract - JBG
RUN export HASH=$(geth --password /root/gethpass account new | awk -vRS='}' -vFS='{' '{print $2}'); \ 
  sed -i -e "s/<COINBASE_HASH>/$HASH/g" /root/hdcoop.json; \
  sed -i -e "s/<COINBASE_HASH>/$HASH/g" /root/run.sh; \
  sed -i -e "s/<COOP_ABI>/$(cat /root/target/Coop.abi)/g" /root/deploy.js; \
  sed -i -e "s/<COOP_BIN>/$(cat /root/target/Coop.bin)/g" /root/deploy.js; \
  geth init /root/hdcoop.json; \
  geth --unlock 0x$HASH --password /root/gethpass --mine 2>> /root/geth.log; \
  geth --unlock 0x$HASH --password /root/gethpass js /root/deploy.js
CMD /root/run.sh

