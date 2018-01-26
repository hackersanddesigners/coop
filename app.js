var url = "http://localhost/api";

function doRequest(opts) {
  return new Promise(function (resolve, reject) {
    var xhr = new XMLHttpRequest();
    xhr.open(!opts.method ? 'GET' : opts.method, url + opts.endpoint);
    xhr.onload = function () {
      if(this.status >= 200 && this.status < 300) {
        resolve(xhr.response);
      } else {
        reject({
          status: this.status,
          statusText: xhr.statusText
        });
      }
    };
    xhr.onerror = function () {
      reject({
        status: this.status,
        statusText: xhr.statusText
      });
    };
    xhr.withCredentials = true;
    xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    if(opts.headers) {
      Object.keys(opts.headers).forEach(function (key) {
        xhr.setRequestHeader(key, opts.headers[key]);
      });
    }
    var params = opts.params;
    if(params && typeof params === 'object') {
      params = Object.keys(params).map(function (key) {
        return encodeURIComponent(key) + '=' + encodeURIComponent(params[key]);
      }).join('&');
    }
    xhr.send(params);
  });
};

var members = [];

/**
 * Helpers - JBG
 */
function memberName(memId) {
  for(var i = 0; i < members.length; i++) {
    if(members[i][0] == memId) return members[i][2];
  }
}

/**
 * APIish stuff - JBG
 */

function appGetActivity(e) {
  var t = e.target.className != 'item' ? e.target.parentNode : e.target;
  var actId = t.getAttribute('data-id');
  console.log(actId);
  doRequest({ 'endpoint': '/activities?actId=' + actId })
  .then((act) => {
    appShowActivity(JSON.parse(act));
  });
}

function appGetActivities() {
  doRequest({ 'endpoint': '/activities' })
  .then((acts) => {
    appShowActivities(JSON.parse(acts));
  });
}

function appGetParticipants(actId) {
  doRequest({ 'endpoint': '/participants?actId=' + actId })
  .then((parts) => {
    appShowParticipants(JSON.parse(parts));
  });
}

function appGetVoteIds(actId) {
  doRequest({ 'endpoint': '/votes?actId=' + actId })
  .then((voteIdsStr) => {
    var voteIds = JSON.parse(voteIdsStr);
    for(var i = 0; i < voteIds.length; i++) {
      appGetVote(voteIds[i]);
    }
  });
}

function appGetVote(voteId) {
  doRequest({ 'endpoint': '/votes?voteId=' + actId })
  .then((vote) => {
    appShowVote(JSON.parse(vote));
  });
}

function appGetMembers() {
  doRequest({ 'endpoint': '/members' })
  .then((mems) => {
    members = JSON.parse(mems);
  });
}

async function appLogin(params) {
  doRequest({
    'endpoint': '/login',
    'method': 'POST',
    'params': params })
  .then(() => {
    appShow();
    console.log("logged in");
  })
  .catch((err, res) => {
    console.log(err);
    console.log(res);
    document.querySelector('.error').innerHTML = "U FAILED.";
  });
}

async function appAddActivity(params) {
  doRequest({
    'endpoint': '/activities',
    'method': 'POST',
    'params': params })
  .then(() => {
    appShow();
    console.log('Activity added');
  })
  .catch((err, res) => {
    document.querySelector('.error').innerHTML = "U FAILED.";
  });
}

/**
 * UI stuff - JBG
 */

function appCreateActivity() {
  console.log('Create activity.');
}

function appShowActivity(act) {
  console.log(act); 
  document.querySelector('.detail').innerHTML = '';
  var activity = document.querySelector('.templates .activity').cloneNode(true)
  document.querySelector('.detail').appendChild(activity);

  activity.querySelector('.title').innerHTML = act[2];
  activity.querySelector('.description').innerHTML = act[3];
  activity.querySelector('.description').setAttribute("href", act[3]);
  activity.querySelector('.cost').innerHTML = act[4].toString();

  appGetParticipants(act[0]);
}

function appShowActivities(acts) {
  for(var i = 0; i < acts.length; i++) {
    var item = document.querySelector('.templates .item').cloneNode(true);
    item.setAttribute('data-id', acts[i][0]);
    item.querySelector('.title').innerHTML = acts[i][2];
    item.querySelector('.description').innerHTML = acts[i][3];
    item.querySelector('.description').setAttribute("href", acts[i][3]);
    item.querySelector('.cost').innerHTML = acts[i][4].toString();
    document.querySelector('.items').appendChild(item);
  }
  var items = document.querySelectorAll('.items .item');
  for(var i = 0; i < items.length; i++) {
    items[i].addEventListener('click', appGetActivity, true);
  };
}

function appShowParticipants(parts) {
  for(var i = 0; i < parts.length; i++) {
    var part = document.querySelector('.templates .participant').cloneNode(true);
    part.innerHTML = memberName(parts[i]);
    document.querySelector('.detail .participants').appendChild(part);
  }
}

function appShowVote(vote) {
  var vote = document.querySelector('.templates .vote').cloneNode(true);
  document.querySelector('.detail .votes').appendChild(vote);
}

function appShowMenu() {
  document.querySelector('.detail').innerHTML = '';
  document.querySelector('.detail').appendChild(
    document.querySelector('.templates .menu').cloneNode(true)
  );
  document.querySelector('.detail .menu .menu-activity')
    .addEventListener('click', appCreateActivity, false);
}

function appShowLogin() {
  document.querySelector('.detail').innerHTML = '';
  document.querySelector('.detail').appendChild(
    document.querySelector('.templates .login').cloneNode(true)
  );
  document.querySelector('.detail .login .button')
    .addEventListener('click', () => {
      appLogin({
        "name": document.querySelector('.detail input[name=name]').value,
        "pwd": document.querySelector('.detail input[name=password]').value
      });
    }, false);
}

function appShowAddMember() {
  document.querySelector('.detail').innerHTML = '';
  document.querySelector('.detail').appendChild(
    document.querySelector('.templates .add-member').cloneNode(true)
  );
}

function appShowAddActivity() {
  document.querySelector('.detail').innerHTML = '';
  document.querySelector('.detail').appendChild(
    document.querySelector('.templates .add-activity').cloneNode(true)
  );
  document.querySelector('.detail .add-activity .button')
    .addEventListener('click', () => {
      appAddActivity({
        "cost": document.querySelector('.detail input[name=cost]').value,
        "title": document.querySelector('.detail input[name=title]').value,
        "description": document.querySelector('.detail input[name=description]').value
      });
    }, false);
}


function appShow() {
  appGetMembers();
  appGetActivities();
  appShowMenu();
}

document.addEventListener('DOMContentLoaded', event => { 
  doRequest({ 'endpoint': '/' })
  .then(() => {
    console.log('auth');
    appShow();
  })
  .catch(() => {
    console.log('no auth');
    appShowLogin();
  });
});

