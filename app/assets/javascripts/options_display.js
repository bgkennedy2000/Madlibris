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
        if (stuff.result == false) {
          $('body').prepend('<div class="alert-box warning text-center">Sorry, and error has occurred.<a href="#" class="close">&times;</a></div>');
        } else {
          $('body').prepend('<div class="alert-box success text-center">User removed from game<a href="#" class="close">&times;</a></div>');
          $("p:contains(" + stuff.user + ")").parent().parent().slideUp();
          optionsDisplay.test = stuff
          var HTML = $('#game' + stuff.game).html();
          $('#game' + stuff.game).html(HTML.replace(stuff.user, ""));
        }
        optionsDisplay.noticeTimeout()
      }
    });
  });
}
optionsDisplay.createAddPlayerForm = function() {
  $('#additional_player').on('click', function(ev) {
    ev.preventDefault();
    ev.stopPropagation();
    $('f-dropdown').addClass("open")
    var newInput = $('<input placeholder="username" id="new_player_username">');
    var $li = $('#additional_player').parent();
    $('#additional_player').replaceWith(newInput);
    $li.append('<li><a id="send_invite" href="#">Send Invite</a></li>');
    optionsDisplay.sendInvite();
  })
}

optionsDisplay.revertLi = function() {

}
optionsDisplay.sendInvite = function() {
  $('#send_invite').on('click', function(ev) {
    $.ajax({
      url: '/send_invite',
      type: 'POST',
      data: { username: $('#new_player_username').val(), game_id: $('#new_player_username').parent().parent().attr('data-game_id') },
      success: function(stuff) {
        if (stuff.result == false) {
          $('body').prepend('<div class="alert-box warning text-center">Username not found<a href="#" class="close">&times;</a></div>');
      } else {
          $('body').prepend('<div class="alert-box success text-center">Invite Sent!<a href="#" class="close">&times;</a></div>');
          optionsDisplay.test = stuff;
          var HTML = $('#game' + stuff.game).html();
          $('#game' + stuff.game).html(stuff.username + " " + HTML);
        }
        optionsDisplay.noticeTimeout();
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
  optionsDisplay.createAddPlayerForm();
});