// hostname
const hostname = location.hostname;
const hostnameElement = document.getElementById("hostname");
hostnameElement.textContent = hostname;

// Time
function displayTime() {
  const now = new Date();
  let hours = now.getHours();
  let minutes = now.getMinutes();
  let seconds = now.getSeconds();
  hours = addLeadingZero(hours);
  minutes = addLeadingZero(minutes);
  seconds = addLeadingZero(seconds);
  const timeString = `${hours}:${minutes}:${seconds}`;
  const timeElement = document.getElementById("time");
  timeElement.textContent = timeString;
}

function addLeadingZero(number) {
  return number < 10 ? "0" + number : number;
}

setInterval(displayTime, 1000);

//random
window.onload = function() {
  const randomNumber = Math.floor(Math.random() * 1000) + 1;
  const resultElement = document.getElementById("result");
  resultElement.textContent = randomNumber;
}

//visitor count
let visitorCount = parseInt(localStorage.getItem("visitorCount")) || 0;
const visitorCountElement = document.getElementById("visitor-count");
visitorCountElement.textContent = visitorCount;

function incrementVisitorCount() {
  visitorCount++;
  visitorCountElement.textContent = visitorCount;
  localStorage.setItem("visitorCount", visitorCount.toString());
}

if (localStorage.getItem("visitorCount") === null) {
  incrementVisitorCount();
}

document.addEventListener("DOMContentLoaded", incrementVisitorCount); 
