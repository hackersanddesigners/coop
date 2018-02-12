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

  int public budget;
  mapping (address => uint) public memberId;

  Member[] public members;
  int public activeMembers;

  Activity[] public activities;
  uint numActivities;

  mapping (uint => uint[]) public parts;
  mapping (uint => uint[]) public voteIds;
  mapping (uint => Vote) public votes;
  uint numVotes;
  
  struct Activity {
    uint actId;
    uint initiatorId;
    int cost;
    string title;
    string description;
    bool passed;
    bool deleted;
    bool global;
  }

  struct Member {
    uint memId;
    address addr;
    string name;
    uint memberSince;
    int balance;
    int promiseAmt;
    bool active;
  }

  struct Vote {
    uint voteId;
    uint actId;
    uint voterId;
    int promise;
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
  function Coop (int initBudget) payable public {
    budget = initBudget;
    addMember(owner, "jbg");
  }

  /**
   *
   */
  function getCoopBudget() public view returns (int) {
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
  int,
  int,
  bool) {
    return (
      members[index].memId,
      members[index].addr,
      members[index].name,
      members[index].memberSince,
      members[index].balance,
      members[index].promiseAmt,
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
      promiseAmt: 0,
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
    int memBudget = budget / activeMembers;
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
   *
   */
  function _createGlobalVotes(uint actId, int cost) private {
    for(uint i = 0; i < members.length; i++) {
      if(members[i].active) {
        _vote(actId, members[i].memId, cost / activeMembers, "");
      }
    }
  }

  /**
   * Add Activity
   *
   * @param cost of the activity 
   * @param description wiki url, description
   */
  function addActivity(
    int cost,
    string title,
    string description,
    bool global
  )
    onlyMembers public
  {
    activities.push(Activity({
      actId: numActivities,
      initiatorId: memberId[msg.sender],
      cost: cost,
      title: title,
      description: description,
      passed: false,
      deleted: false,
      global: global
    }));
    
    addParticipant(memberId[msg.sender], numActivities);

    if(global) { _createGlobalVotes(numActivities, cost); }

    numActivities++;
  }

  /**
   *
   */
  function _tallyPromises(uint actId) private view returns (int) {
    int promise = 0;
    for(uint i = 0; i < voteIds[actId].length; i++) {
      Vote memory vote = votes[voteIds[actId][i]];
      if(actId == vote.actId && !vote.deleted) {
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
  string,
  int,
  bool,
//  bool,
  int) {
    return (
      activities[index].actId,
      activities[index].initiatorId,
      activities[index].title,
      activities[index].description,
      activities[index].cost,
      activities[index].passed,
//      activities[index].global,
      _tallyPromises(activities[index].actId)
    );
  }

  /**
   *
   */
  function isParticipant(uint memId, uint actId)  onlyMembers public view returns (bool) {
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
  function getParticipants(uint actId) onlyMembers public view returns (uint[]) {
    return parts[actId];
  }

  /**
   *
   */
  function voted(uint memId, uint actId) public view returns (bool) {
    for(uint i = 0; i < voteIds[actId].length; i++) {
      if(memId == votes[voteIds[actId][i]].voterId &&
        !votes[voteIds[actId][i]].deleted) {
        return true;
      } 
    }
    return false;
  } 

  /**
   *
   */
  function _vote(
    uint actId,
    uint memId,
    int promise,
    string justification
  )
    onlyMembers public
  {
    voteIds[actId].push(numVotes);

    Vote storage v = votes[numVotes];
    v.voteId = numVotes;
    v.actId = actId;
    v.voterId = memId; 
    v.promise = promise;
    v.justification = justification;
    v.deleted = false;

    numVotes++;

    members[memId].promiseAmt += promise;
  } 

  /**
   *
   */
  function vote(
    uint actId,
    int promise,
    string justification 
  )
    onlyMembers public
  {
    Member storage mem = members[memberId[msg.sender]];

    require(
      !isParticipant(memberId[msg.sender], actId) &&
      promise <= (mem.balance - mem.promiseAmt) &&
      !voted(memberId[msg.sender], actId)
    );
    
    _vote(actId, memberId[msg.sender], promise, justification);

  }

  /**
   *
   */
  function getVoteIds(uint actId) public view returns (uint[]) {
    return voteIds[actId];
  }

  /**
   *
   */
  function getVote(uint voteId) public view returns (
    uint,
    uint,
    uint,
    int,
    string,
    bool) {
    return (
      votes[voteId].voteId,
      votes[voteId].actId,
      votes[voteId].voterId,
      votes[voteId].promise,
      votes[voteId].justification,
      votes[voteId].deleted
    );
  }

  /**
   *
   */
  function deleteVote(uint voteId) onlyMembers public {
    require(!activities[votes[voteId].actId].global);
    votes[voteId].deleted = true;
  }

  /**
   *
   */
  function finalize(uint actId) onlyMembers public {
    Activity storage activity = activities[actId];
    require(
      !activities[actId].passed &&
      _tallyPromises(actId) >= activities[actId].cost);

    for(uint i = 0; i < voteIds[actId].length; i++) {
      Vote storage v = votes[voteIds[actId][i]];
      if(!v.deleted) {
        Member storage member = members[v.voterId];
        member.balance -= v.promise;
        member.promiseAmt -= v.promise;
      }
    }

    activity.passed = true;
  }
  
}

