var loadActivities = () => {
  var acts = getActivities();
  for(var i = 0; i < acts.length; i++) {
    var item = document.querySelector('.templates .item').cloneNode(true);
    item.querySelector('.title').innerHTML = acts[i][2];
    item.querySelector('.description').innerHTML = acts[i][3];
    item.querySelector('.cost').innerHTML = acts[i][1].toString();
    document.querySelector('.items').appendChild(item);
  }
};

document.addEventListener('DOMContentLoaded', event => { 
  console.log("app.js...");
  loadActivities();
});

