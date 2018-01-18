const web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'));
const cc = web3.eth.contract(abi);
const ci = cc.at(contractAddress);

function addMember(i) {
  return new Promise(resolve => {
    ci.addMember(
      web3.eth.accounts[i+1],
      'user-' + (i+1),
      {from: web3.eth.accounts[0], gas:1000000},
      () => {
        resolve('User added.');
      }
    );
  });
}

async function addMembers() {
  for(var i = 0; i < 3; i++) {
    console.log(await addMember(i));
  }
  console.log('# members: ' + ci.memberCount.call().toString());
}

function distributeBudget() {
  return new Promise(resolve => {
    ci.distributeBudget({from: web3.eth.accounts[0], gas: 1000000}, () => {
      resolve('distributeBudget...done.');
    });
  });
}

function checkResults() {
  console.log('Total budget: ' + ci.getCoopBudget.call().toString());
  // Did users get funds? - JBG 
  for(var i = 0; i < ci.memberCount.call(); i++) {
    console.log(ci.getMember.call(i).toString());
  }
}

function checkActivities() {
  for(var i = 0; i < ci.activityCount.call(); i++) {
    console.log(ci.getActivity.call(i).toString());
  }
}

function getActivities() {
  var acts = [];
  for(var i = 0; i < ci.activityCount.call(); i++) {
    console.log("HERE");
    acts.push(ci.getActivity.call(i));
  }
  return acts;
}

function removeMember(addr) {
   return new Promise(resolve => {
    ci.deactivateMember(
      addr,
      {from: web3.eth.accounts[0], gas:1000000},
      () => {
        resolve('User removed.');
      }
    );
  });
}

function addActivity(cost, title, description) {
  return new Promise(resolve => {
    ci.addActivity(
      cost,
      title,
      description, 
      {from: web3.eth.accounts[0], gas:1000000},
      () => {
        resolve('Activity added.');
      }
    );
  });
}

function addParticipant(memId, actId) {
  return new Promise(resolve => {
    ci.addParticipant(
      memId,
      actId, 
      {from: web3.eth.accounts[0], gas:1000000},
      () => {
        resolve('Participant added.');
      }
    );
  });
}

function removeParticipant(memId, actId) {
  return new Promise(resolve => {
    ci.removeParticipant(
      memId,
      actId, 
      {from: web3.eth.accounts[0], gas:1000000},
      () => {
        resolve('Participant removed.');
      }
    );
  });
}

function vote(actId, prom, just) {
  return new Promise(resolve => {
    ci.vote(
      actId,
      prom,
      just,
      {from: web3.eth.accounts[0], gas:1000000},
      () => {
        resolve('Vote added.');
      }
    );
  });
}

function finalize(actId) {
  return new Promise(resolve => {
    ci.finalize(
      actId,
      {from: web3.eth.accounts[0], gas:1000000},
      () => {
        resolve('Activity finalized.');
      }
    );
  });
}


async function initialize() {
  console.log(await distributeBudget());
  checkResults();
//  console.log(await removeMember(web3.eth.accounts[1]));
//  checkResults();
  console.log(await addActivity(1000, "Some title", "http://wiki..."));
  console.log('# activities: ' + ci.activityCount.call().toString());
  checkActivities();
//  console.log(await addParticipant(1, 0));
//  console.log(await addParticipant(2, 0));
//  console.log('participants: ' + ci.getParticipants.call(0).toString());
//  console.log(await removeParticipant(2, 0));
//  console.log('participants: ' + ci.getParticipants.call(0).toString());
//  console.log(await addParticipant(2, 0));
//  console.log('participants: ' + ci.getParticipants.call(0).toString());
//  console.log(await vote(0, 1000, "Great idea."));
//  console.log('# activities: ' + ci.activityCount.call().toString());
//  checkActivities();
//  console.log('Vote Ids: ' + ci.getVoteIds.call(0));
//  console.log('Vote: ' + ci.getVote(ci.getVoteIds.call(0)[0]));
//  console.log(await finalize(0));
//  checkResults();
//  checkActivities();
}

document.addEventListener('DOMContentLoaded', event => { 
  console.log(contractAddress);
  console.log(web3.eth.accounts[0]);

  // Sanity check - JBG
  console.log('Total budget: ' + ci.getCoopBudget.call().toString());
  console.log(ci.getMember.call(0).toString());

  // Add 3 more members, distribute budget - JBG
  addMembers().then(() => {
    initialize();
  });

});
