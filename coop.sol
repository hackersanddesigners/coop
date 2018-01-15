pragma solidity ^0.4.16;

contract owned {
  address public owner;

  function owned()  public {
    owner = msg.sender;
  }

  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) onlyOwner  public {
    owner = newOwner;
  }
}

contract Coop is owned {

  uint public budget;
  mapping (address => uint) public memberId;

  Member[] public members;
  uint public activeMembers;

  Activity[] public activities;
  mapping (uint => uint[]) public parts;
  uint public numVotes;
  mapping (uint => Vote[]) public votes;
  
  struct Activity {
    uint actId;
    uint initiatorId;
    uint cost;
    string description;
    bool passed;
    bool deleted;
  }

  struct Member {
    uint memId;
    address addr;
    string name;
    uint memberSince;
    uint balance;
    bool active;
  }

  struct Vote {
    uint voteId;
    uint actId;
    uint voterId;
    uint promise;
    string justification;
    bool deleted;
  }

  // Modifier that allows only shareholders to vote and create new activities
  modifier onlyMembers {
    require(msg.sender == owner || memberId[msg.sender] != 0);
    _;
  }

  /**
   * Constructor function
   */
  function Coop (uint initBudget) payable public {
    budget = initBudget;
    addMember(owner, 'jbg');
  }

  /**
   *
   */
  function getCoopBudget() public view returns (uint) {
    return budget;
  }

  /**
   *
   */
  function getMember(uint index) public view returns (
  uint,
  address,
  string,
  uint,
  uint,
  bool) {
    return (
      members[index].memId,
      members[index].addr,
      members[index].name,
      members[index].memberSince,
      members[index].balance,
      members[index].active
    );
  }

  /**
   *
   */
  function memberCount() public view returns (uint) {
    return members.length;
  }

  /**
   * Add member
   *
   * Make `targetMember` a member named `memberName`
   *
   * @param targetMember ethereum address to be added
   * @param memberName public name for that member
   */
  function addMember(address targetMember, string memberName) onlyOwner public {
    require(memberId[targetMember] == 0);
    memberId[targetMember] = members.length;

    members.push(Member({
      memId: memberId[targetMember],
      addr: targetMember,
      memberSince: now,
      name: memberName,
      balance: 0,
      active: true
    }));

    activeMembers++;
  }

  /**
   * Remove member
   *
   * @notice Remove membership from `targetMember`
   *
   * @param targetMember ethereum address to be removed
   */
  function deactivateMember(address targetMember) onlyOwner public {
    require(memberId[targetMember] != 0);
    members[memberId[targetMember]].active = false;
    budget += members[memberId[targetMember]].balance;
    members[memberId[targetMember]].balance = 0;
    activeMembers--;
  }

  /**
   *
   */
  function distributeBudget() onlyOwner public {
    uint memBudget = budget / activeMembers;
    for(uint i = 0; i < members.length; i++) {
      if(members[i].active) {
        members[i].balance = members[i].balance + memBudget; 
      }
    }
    budget = 0;
  }

  /**
   *
   */
  function activityCount() public view returns (uint) {
    return activities.length;
  }

  /**
   * Add Activity
   *
   * @param cost of the activity 
   * @param description wiki url, description
   */
  function addActivity(
    uint cost,
    string description
  )
    onlyMembers public
  {
    activities.push(Activity({
      actId: activities.length,
      initiatorId: memberId[msg.sender],
      cost: cost,
      description: description,
      passed: false,
      deleted: false
    }));
  }

  /**
   *
   */
  function _tallyPromises(uint actId) private view returns (uint) {
    uint promise = 0;
    for(uint i = 0; i < votes[actId].length; i++) {
      Vote memory vote = votes[actId][i];
      if(actId == vote.actId) {
        promise += vote.promise;
      }
    }
    return promise;
  }

  /**
   *
   */
  function getActivity(uint index) public view returns (
  uint,
  uint,
  string,
  uint,
  bool,
  uint) {
    return (
      activities[index].actId,
      activities[index].initiatorId,
      activities[index].description,
      activities[index].cost,
      activities[index].passed,
      _tallyPromises(activities[index].actId)
    );
  }

  /**
   *
   */
  function isParticipant(uint memId, uint actId)  onlyMembers public returns (bool) {
    for(uint i = 0; i < parts[actId].length; i++) {
      if(parts[actId][i] == memId) {
        return true;
      }
    }
    return false;
  } 

  /**
   *
   */
  function addParticipant(uint memId, uint actId) onlyMembers public {
    require(!isParticipant(memId, actId));
    parts[actId].push(memId);
  } 

  /**
   *
   */
  function removeParticipant(uint memId, uint actId) onlyMembers public {
    for(uint i = 0; i < parts[actId].length; i++) {
      if(parts[actId][i] == memId) {
        delete parts[actId][i];
        parts[actId].length--;
      }
    }
  } 


  /**
   *
   */
  function getParticipants(uint actId) onlyMembers public returns (uint[]) {
    return parts[actId];
  }

  /**
   *
   */
  function voted(uint memId, uint actId) public view returns (bool) {
    for(uint i = 0; i < votes[actId].length; i++) {
      if(memId == votes[actId][i].voterId) {
        return true;
      } 
    }
    return false;
  } 

  /**
   *
   */
  function vote(
    uint actId,
    uint promise,
    string justification 
  )
    onlyMembers public
  {

    require(
      !isParticipant(memberId[msg.sender], actId) &&
      !voted(memberId[msg.sender], actId)
    );

    votes[actId].push(Vote({
      voteId: numVotes,
      actId: actId,
      voterId: memberId[msg.sender],
      promise: promise,
      justification: justification,
      deleted: false
    }));
    numVotes++;

  }
}

