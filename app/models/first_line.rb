class FirstLine < ActiveRecord::Base
  attr_accessible :book_id, :true_line, :text, :user_id, :state, :introductory_content_id, :game_user_id
  
  belongs_to :book
  belongs_to :game_user
  belongs_to :user
  has_many :line_choices
  belongs_to :introductory_content
  has_many :first_lines_rounds
  has_many :rounds, through: :first_lines_rounds

  validates :true_line, :inclusion => {:in => [true, false]}
  validate :fake_line_has_game_user?
  validate :fake_line_has_user?

  include AASM

  aasm :column => 'state' do
    state :pending, :initial => true
    state :written

    event :write do

      transitions :from => :pending, :to => :written
    end

  end

  def fake_line_has_user?
    if self.true_line == false
      errors.add(:base, "Fake lines require a user_id") unless self.user
    end
  end

  def fake_line_has_game_user?
    if self.true_line == false
      errors.add(:base, "Fake lines require a game_user_id") unless self.game_user_id
    end
  end



end
