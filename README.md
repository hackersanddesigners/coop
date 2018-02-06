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

> personal.newAccount("password")
> eth.getBalance(eth.coinbase)
> eth.accounts
> miner.start()
> miner.stop()
 

geth --networkid 1337 --rpc --rpcapi "eth,net,web3,admin,personal" console 2>> geth.log

docker start -ia hd-coop
docker exec -it hd-coop bash

solc -o target --bin --abi coop.sol

> personal.unlockAccount(eth.coinbase, "password")

var coopFactory = eth.contract(<contents of the file coop.abi>)
var coopCompiled = "0x" + "<contents of the file coop.bin>"



var _budget = 10000; 

var coop = coopFactory.new(_budget, { from: eth.accounts[0], data:coopCompiled, gas:100000000 }, function(e, contract) {
    if(!e) {
      if(!contract.address) {
        console.log("Contract transaction send: TransactionHash: " + contract.transactionHash + " waiting to be mined...");

      } else {
        console.log("Contract mined! Address: " + contract.address);
        console.log(contract);
      }
    }
})

0xc156d9ea3fb7e181a91e0ec0fd68b36a4b283064

apt-get install nginx
apt-get install build-essential
/usr/sbin/nginx

curl -sL https://deb.nodesource.com/setup_8.x | bash -
apt-get install -y nodejs



curl --cookie-jar cookies.txt -d "name=jbg&pwd=<YOUR_PASSPHRASE>" "http://localhost/api/login"
curl --cookie cookies.txt -d "name=andre&addr=0x0f764540f362d1e88e59432cf1c130cd285c8155" "http://localhost/api/members"
curl --cookie cookies.txt -X POST "http://localhost/api/budget"
curl --cookie cookies.txt -X POST "http://localhost/api/budget"


curl --cookie cookies.txt -d "cost=1000&title=Fun&description=Yes" "http://localhost/api/activities"




const tx = await MyContract.MyMethod.sendTransaction(MyParams);

eth.sendTransaction({from:eth.coinbase, to:eth.accounts[1], value: web3.toWei(0.05, "ether")})

