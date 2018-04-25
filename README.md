# coop

## Start a Docker container

`$ docker run -it --name hd-coop  -p 8545:8545 -p 80:80 ubuntu:latest`

## Install dependencies

`$ apt-get update`

`$ apt-get install software-properties-common git curl nginx`

`$ add-apt-repository -y ppa:ethereum/ethereum`

`$ apt-get update`

`$ apt-get install ethereum`

`$ apt-get install solc`

## Create Geth account

`$ geth account new`. Save the id somewhere for later.

## Run puppeth wizard

`$ puppeth`

### Configure example 

```
Please specify a network name to administer (no spaces or hyphens, please)
> hdcoop

What would you like to do? (default = stats)
 1. Show network stats
 2. Configure new genesis
 3. Track new remote server
 4. Deploy network components
> 2

Which consensus engine to use? (default = clique)
 1. Ethash - proof-of-work
 2. Clique - proof-of-authority
> 2

How many seconds should blocks take? (default = 15)
> (press enter) 

Which accounts are allowed to seal? (mandatory at least one)
> 0xddaebdd6966bf50584b73f14e07a5fd0754207b2 (replace with your account id)
> 0x

Which accounts should be pre-funded? (advisable at least one)
> 0xddaebdd6966bf50584b73f14e07a5fd0754207b2
> 0x

Specify your chain/network ID if you want an explicit one (default = random)
> (press enter)

What would you like to do? (default = stats)
 1. Show network stats
 2. Manage existing genesis
 3. Track new remote server
 4. Deploy network components
> 

What would you like to do? (default = stats)
 1. Show network stats
 2. Manage existing genesis
 3. Track new remote server
 4. Deploy network components
> 2

 1. Modify existing fork rules
 2. Export genesis configuration
 3. Remove genesis configuration
> 2

Which file to save the genesis into? (default = hdcoop.json)
> (press enter)

press ctrl + C to stop and exit from the puppeth wizard process
```

## Git clone Repo

`$ git clone https://github.com/hackersanddesigners/coop.git`

## Compile the contract

`$ solc -o target --bin --abi coop.sol`

## Create a helper file that contains the geth password

`$ echo <YOUR_PASSPHRASE> >> gethpass`

## Start Geth

`$ geth --unlock <geth-account> --password /root/gethpass --mine --rpc --rpcapi "eth,net,web3,admin,personal" console 2>> geth.log`

### Set the contents of the ABI (should be in the target dir from the solc command, Coop.abi)

`> var coopFactory = eth.contract(<contents of the file coop.abi>)`

### Set the contents of the Contract (also in the target dir from the solc command, Coop.bin)

`> var coopCompiled = "0x" + "<contents of the file coop.bin>"`

### Set the initial arguments for the contract, in this case budget

`> var _budget = 10000;`

### Submit the contract

```
> var coop = coopFactory.new(_budget, { from: eth.coinbase, data:coopCompiled gas: 4000000 }, function(e, contract) {
    if(!e) {
      if(!contract.address) {
        console.log("Contract transaction send: TransactionHash: " + contract.transactionHash + " waiting to be mined...");

      } else {
        console.log("Contract mined! Address: " + contract.address);
        console.log(contract);
      }
    } else {
      console.log(e);
    }
})
```

### IMPORTANT make note of the address that pops out once the contract is mined.  You are going to need it later.


### Create some test accounts (doesn't really matter the number) in Geth

`> personal.newAccount("password")`

### Send Ether to the new accounts

`> eth.sendTransaction({from:eth.coinbase, to:eth.accounts[1], value: web3.toWei(1.0, "ether")})`

## Setting up the server

### Create a .js (javascript) file with credentials

```
exports.creds = {
  "jbg": {
    "pwd": "password",
    "addr": "0x4e858..."
  },
  "selby": {
    "pwd": "password",
    "addr": "0xd8852..."
  },
  "anja": {
    "pwd": "password",
    "addr": "0x27c84..."
  },
  "andre": {
    "pwd": "password",
    "addr": "0x000a2..."
  },
  "juliette": {
    "pwd": "password",
    "addr": "0xd939a..."
  },
  "heerko": {
    "pwd": "password",
    "addr": "0xd092d..."
  }
};
```

Replace the "addr" bits with the accounts created in Geth, and the password with the passwords you gave to Geth.

### Update abi.js

Set `exports.abi = ` to the content of Coop.abi in the target directory created during the `solc` step.

### Update address.js

Set `exports.contractAddress = ` to the address that you took note of earlier, that popped up after the contract was mined.

## Install node.js

`$ curl -sL https://deb.nodesource.com/setup_8.x | bash -`

`$ apt-get install -y nodejs`

## Start the coopserver

`$ node server.js`

## Configure nginx

Add a proxy pass for the node.js server.

```
location /api {
     proxy_pass http://localhost:3000;
}
```

## Start nginx

`$ nginx`

## Helper docker commands

### Start your container

`$ docker start -ia hd-coop`

### Shell into a running container

`$ docker exec -it hd-coop bash`

## Helper geth commands

### Unlock account

`> personal.unlockAccount(eth.coinbase, "password")`

### Get account balance

`> eth.getBalance(eth.coinbase)`

### Start miner

`> miner.start()`

### Stop miner

`> miner.stop()`

### Check current gas limit

`> eth.getBlock("latest")`

## cURL Examples

## Login

`$ curl --cookie-jar cookies.txt -d "name=jbg&pwd=password" "http://localhost/api/login"`

## Add a member

`$ curl --cookie cookies.txt -d "name=andre&addr=0x0f764540f362d1e88e59432cf1c130cd285c8155" "http://localhost/api/members"`

## DISTRIBUTE BUDGET

`$ curl --cookie cookies.txt -X POST "http://localhost/api/budget"`

## Create activity

`$curl --cookie cookies.txt -d "cost=1000&title=Fun&description=Yes" "http://localhost/api/activities"`

## Other commands

### Stop nginx

`$ nginx -s stop`
 
## To start up the whole stack when developing

To access already existing docker image:

- `docker start -ia hd-coop` 

or if already running:

- `docker exec -it hd-coop bash` 

Then to start mining:

- `cd ~ && geth --unlock <geth-account-id> --password /root/gethpass --mine --rpc --rpcapi "eth,net,web3,admin,personal" console 2>> geth.log`

Open new terminal window and do:

- `docker exec -it hd-coop bash`
- `tail -f geth.log`

Open new terminal window and do:

- `docker exec -it hd-coop bash`
- `cd ~/coopserv/ && node server.js`
	- if problems when running the server: 
		- `ps aux | grep node`
		- `pkill node` 
