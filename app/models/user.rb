class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and 
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, omniauth_providers: [:facebook, :twitter]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :username, :password, :password_confirmation, :remember_me, :uid, :provider
  
  has_many :games_users
  has_many :games, through: :games_users
  has_many :rounds, through: :games
  has_many :notifications
  has_many :first_lines
  has_many :first_lines_rounds

  validate :nickname_or_email?
  validates :username, uniqueness: true
  
  after_create :welcome_email

  def invited_madlibris_games
    pending_invites.collect { |games_user| games_user.game  }.compact
  end

  def ongoing_madlibris_games
    accepteds.collect { |games_user| games_user.game }.compact
  end

  def my_move?(game)
    games_user = get_accepted_games_user(game)
    truth_array = game.rounds.collect { |round| 
      games_user.my_move?(round)
    }
  end

  def choose_first_line(round, first_line)
    line_choice = get_line_choice(round)
    line_choice.first_line_id = first_line.id
    line_choice.complete if line_choice.may_complete?
    round = Round.find(round.id)

    round.complete if round.may_complete?
  end

  def get_line_choice(round)
    games_user = get_accepted_games_user(round.game)
    games_user.get_line_choice(round)
  end

  def draft_first_line(round, text)
    first_line = get_first_line(round)
    first_line.update_attributes(text: text)
    first_line.write
    round = Round.find(round.id)
    if round.all_first_lines_written?
      round.all_lines_complete 
    end
  end

  def get_first_line(round)
    games_user = get_accepted_games_user(round.game)
    first_line = round.first_lines.select{ |line| line.games_user_id == games_user.id }[0]
  end


  def choose_book(round, book)
    round = make_book_choice(round, book) 
    messages = round.get_line_choosers_games_users.map {
      |games_user|
      if round.create_first_line_and_associate_to_round(games_user, book)
        games_user.user.notifications.create(text: "#{self.username} choose a #{book.title} to be the book for this round.  Please read about this book and try to draft what you think might be the first sentence of this book.")
      end
    }
    messages
  end

  def host?(game)
    games_users = games_users.where_host
    truth_array = games.map { |games_user| games_user.game.id == game.id }
    truth_array.include?(true)
  end

  def make_book_choice(round, book)
    round.book_choice.book_id = book.id
    round.book_choice.games_user_id = get_accepted_games_user(round.game).id
    if round.book_choice.complete
      round.play
    end
    round
  end


  def new_game(kind)
    game = MadlibrisGame.create(kind: kind)
    games_user = games_users.create(game_id: game.id, user_role: "host")
    if game.save
      # invite themselves to the game to transition state
      games_user.invite
      games_user.accept
      [game, games_user]
    else  
      false
    end
  end

  def invite_existing_user(user, game)
    games_user = user.games_users.create(game_id: game.id, user_role: "invitee")
    if game.save
      games_user.send_invite
      [game, games_user]
    else
      false
    end
  end

  def invite_new_user(email, game)

    #create after devise invitable implemented

  end

  def pending_invites
    games_users.pendings
  end

  def accepteds
    games_users.accepteds
  end

  def accept_invitation(game)
    games_user = get_pending_games_user(game)
    games_user.try(:accept) 
    games_user
  end

  def reject_invitation(game)
    games_user = get_pending_games_user(game)
    games_user.try(:reject)
    games_user
  end

  def uninvite_from_game(user, game)
    games_user = user.get_pending_games_user(game) 
    games_user ||= user.get_accepted_games_user(game)
    if host?(game) && games_user.may_kick_out?
      games_user.kick_out
    end
    games_user
  end

  def host?(game)
    games_user = get_pending_games_user(game) 
    games_user ||= get_accepted_games_user(game)
    if games_user.try(:user_role) == "host"
      true
    else
      false
    end
  end

  def get_pending_games_user(game)
    pending_invites.select { |games_user| games_user.try(:game) == game }[0]
  end

  def get_accepted_games_user(game)
    accepteds.select { |games_user| games_user.try(:game) == game }[0]
  end

  def nickname_or_email?
    if self.email == "" && self.nickname == ""
      errors.add(:base, "An email address or a twitter handle is required.") 
    end
  end

  def welcome_email
    if self.email
      UserMailer.registration_confirmation(self).deliver
    end
  end  


  def email_required?
    false
  end


  def self.from_omniauth(auth)
    case auth.provider 
    when "twitter"
      if user = User.find_by_nickname("@" + auth.info.nickname)
        user.provider = auth.provider
        user.uid = auth.uid
        user
      else
        where(auth.slice(:provider, :uid)).first_or_create do |user|
          user.provider = auth.provider
          user.uid = auth.uid
          user.nickname = "@" + auth.info.nickname
          user.username = auth.info.nickname
          user.password = Devise.friendly_token[0,20]
        end
      end
    when "facebook"
      if user = User.find_by_email(auth.info.email)
        user.provider = auth.provider
        user.uid = auth.uid
        user
      else
        where(auth.slice(:provider, :uid)).first_or_create do |user|
          user.provider = auth.provider
          user.uid = auth.uid
          user.email = auth.info.email
          user.password = Devise.friendly_token[0,20]
          index = user.email.index('@')
          user.username = user.email[0..(index -1)]
        end
      end
    end   
  end


end
