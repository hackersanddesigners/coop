var loadActivities = () => {
  var acts = getActivities();
  for(var i = 0; i < acts.length; i++) {
    var item = document.querySelector('.templates .item').cloneNode();
    item.querySelector('.title').innerHTML = acts[i].title;
    item.querySelector('.description').innerHTML = acts[i].description;
    item.querySelector('.cost').innerHTML = acts[i].cost;
    document.querySelector('.items').appendChild(item);
  }
};

document.addEventListener('DOMContentLoaded', event => { 
  console.log("app.js...");
  loadActivities();
});

