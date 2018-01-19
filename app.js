var appCreateActivity = () => {
  console.log('Create activity.');
};

var appActivityDetail = (e) => {
  var t = e.target.className != 'item' ? e.target.parentNode : e.target;
  var actId = t.getAttribute('data-id');
  var act = getActivity(actId);

  document.querySelector('.detail').innerHTML = '';
  var activity = document.querySelector('.templates .activity').cloneNode(true)
  document.querySelector('.detail').appendChild(activity);

  activity.querySelector('.title').innerHTML = act[2];
  activity.querySelector('.description').innerHTML = act[3];
  activity.querySelector('.description').setAttribute("href", act[3]);
  activity.querySelector('.cost').innerHTML = act[4].toString();

  var parts = getParticipants(actId);
  console.log(parts);
  for(var i = 0; i < parts.length; i++) {
    var part = parts[i];
  }

};

var appLoadActivities = () => {
  var acts = getActivities();
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
    items[i].addEventListener('click', appActivityDetail, true);
  };
};

var appShowMenu = () => {
  document.querySelector('.detail').innerHTML = '';
  document.querySelector('.detail').appendChild(
    document.querySelector('.templates .menu').cloneNode(true)
  );
  document.querySelector('.detail .menu .create')
    .addEventListener('click', appCreateActivity, false);
};

var appShowLogin = () => {
  document.querySelector('.detail').innerHTML = '';
  document.querySelector('.detail').appendChild(
    document.querySelector('.templates .login').cloneNode(true)
  );
  document.querySelector('.detail .login .button')
    .addEventListener('click', appLogin, false);
};

var appLogin = () => {
  appLoadActivities();
  appShowMenu();
};

document.addEventListener('DOMContentLoaded', event => { 
  console.log("app.js...");
  appShowLogin();
});

