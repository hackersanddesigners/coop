var coopFactory = eth.contract(<COOP_ABI>)
var coopCompiled = "0x" + "<COOP_BIN>"
var _budget = 10000

var coop = coopFactory.new(_budget, { from: eth.coinbase, data:coopCompiled gas: 4000000 }, function(e, contract) {
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

