var optionsDisplay = optionsDisplay || {}

optionsDisplay.setupAccordion = function() {
  var currentGamesCount = $('#current_games').attr('data_current_games');
  var currentGamesCount = parseInt(currentGamesCount);
  var invites = $('#pending_invites').attr('data_invites');
  var invitesCount = parseInt(invites);
  if (currentGamesCount === 0 && invitesCount === 0 ) {
    $('#invite').addClass("active");    
    $('#current_games').removeClass("active");
  }
  if (currentGamesCount === 0) {
    $('#current_games').removeClass("active");
  }
  if (invitesCount > 0 ) {
    $('#pending_invites').addClass("active");
    $('#current_games').removeClass("active");
  } 
}

optionsDisplay.noticeTimeout = function(){
  setTimeout(function(){ $('.alert-box').slideUp() }, 5000);
}

optionsDisplay.uninvite = function(){
  $('p.uninvite').on('click', function(ev) {
    $.ajax({
      url: '/uninvite',
      type: 'POST',
      data: { username: $(this).attr('data-username'), game_id: $(this).attr('data-game_id') },
      success: function(stuff) {
        alert(stuff);
        $(this).parent().parent().slideUp();
      }
    });
  });
}


$(document).ready(function(){
  $('.disabled').click( function(ev) {
    ev.preventDefault();
  });
  $('.hide-button').hide();
  optionsDisplay.setupAccordion();
  optionsDisplay.noticeTimeout();
  optionsDisplay.uninvite();
});