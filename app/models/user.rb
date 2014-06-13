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

  validate :nickname_or_email?
  
  after_create :welcome_email

  def new_game(kind)
    game = MadlibrisGame.create(kind: kind)
    game_user = games_users.create(game_id: game.id, user_role: "host")
    if game.save
      # invite themselves to the game to transition state
      game_user.invite
      game_user.accept
      [game, game_user]
    else  
      false
    end
  end

  def invite_existing_user(user, game)
    game_user = user.games_users.create(game_id: game.id, user_role: "invitee")
    if game.save
      game_user.send_invite
      [game, game_user]
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
    game_user = get_pending_game_user(game)
    game_user.try(:accept) 
    game_user
  end

  def reject_invitation(game)
    game_user = get_pending_game_user(game)
    game_user.try(:reject)
    game_user
  end

  def uninvite_from_game(user, game)
    game_user = user.get_pending_game_user(game) 
    game_user ||= user.get_accepted_game_user(game)
    if host?(game) && game_user.may_kick_out?
      game_user.kick_out
    end
    game_user
  end

  def host?(game)
    game_user = get_pending_game_user(game) 
    game_user ||= get_accepted_game_user(game)
    if game_user.user_role == "host"
      true
    else
      false
    end
  end

  def get_pending_game_user(game)
    pending_invites.select { |games_user| games_user.try(:game) == game }[0]
  end

  def get_accepted_game_user(game)
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
