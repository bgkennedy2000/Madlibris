var optionsDisplay = optionsDisplay || {}

optionsDisplay.setupAccordion = function() {
  var currentGamesCount = $('#current_games').attr('data_current_games');
  var currentGamesCount = parseInt(currentGamesCount);
  var invites = $('#pending_invites').attr('data_invites');
  var invitesCount = parseInt(invites);
  if (currentGamesCount === 0 && invitesCount > 0 ) {
    $('#current_games').removeClass("active");
    $('#pending_invites').addClass("active");
  } else if (currentGamesCount === 0) {
    $('#invite').addClass("active");
    $('#current_games').removeClass("active");
  } else {

  }
}

optionsDisplay.noticeTimeout = function(){
  setTimeout(function(){ $('.alert-box').slideUp() }, 5000);
}



$(document).ready(function(){
  $('.disabled').click( function(ev) {
    event.preventDefault();
  });
  $('.hide-button').hide();
  optionsDisplay.setupAccordion();
  optionsDisplay.noticeTimeout();
});