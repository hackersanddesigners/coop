# coop

## notes -- at some point this might be really documentation....lol.

docker run -it --name hd-coop  -p 8545:8545 -p 80:80 ubuntu:latest

apt-get update
apt-get install software-properties-common
add-apt-repository -y ppa:ethereum/ethereum
apt-get update
apt-get install ethereum
apt-get install solc 

geth init genesis.json
geth --networkid 1337 console

> personal.newAccount("<YOUR_PASSPHRASE>")
> eth.getBalance(eth.coinbase)
> eth.accounts
> miner.start()
> miner.stop()
 

geth --networkid 1337 --rpc --rpcapi "eth,net,web3,admin"

docker start -ia hd-coop

solc -o target --bin --abi coop.sol

> personal.unlockAccount(web3.eth.accounts[0], "<YOUR_PASSPHRASE>")

var coopFactory = eth.contract(<contents of the file coop.abi>)
var coopCompiled = "0x" + "<contents of the file coop.bin>"



var _budget = 10000; 

var coop = coopFactory.new(_budget, { from: eth.accounts[0], data:coopCompiled, gas:47000000 }, function(e, contract) {
    if(!e) {
      if(!contract.address) {
        console.log("Contract transaction send: TransactionHash: " + contract.transactionHash + " waiting to be mined...");

      } else {
        console.log("Contract mined! Address: " + contract.address);
        console.log(contract);
      }
    }
})

0x0e54e2c3a14b064f2074c8f44bb4ce5120ae4c8c

apt-get install nginx
/usr/sbin/nginx


