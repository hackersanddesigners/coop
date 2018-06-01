#!/bin/bash

# Start geth - JBG
geth --unlock 0x<COINBASE_HASH> --password /root/gethpass --mine --rpc --rpcapi "eth,net,web3,admin,personal" 2>> /root/geth.log

