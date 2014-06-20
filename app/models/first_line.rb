class FirstLine < ActiveRecord::Base
  attr_accessible :book_id, :true_line, :text, :user_id, :state, :introductory_content_id, :games_user_id
  
  belongs_to :book
  belongs_to :games_user
  belongs_to :user
  has_many :line_choices
  belongs_to :introductory_content
  has_many :first_lines_rounds
  has_many :rounds, through: :first_lines_rounds

  validates :true_line, :inclusion => {:in => [true, false]}
  validate :fake_line_has_games_user?
  # validate :fake_line_has_user?

  scope :true_line, -> { where("true_line = ?", true ) } 

  include AASM

  aasm :column => 'state', :whiny_transitions => false do
    state :pending, :initial => true
    state :written

    event :write do
      after do
        save
      end

      transitions :from => :pending, :to => :written
    end

  end

  # def fake_line_has_user?
  #   if self.true_line == false
  #     errors.add(:base, "Fake lines require a user_id") unless self.user
  #   end
  # end

  def fake_line_has_games_user?
    if self.true_line == false
      errors.add(:base, "Fake lines require a games_user_id") unless self.games_user_id
    end
  end



end
