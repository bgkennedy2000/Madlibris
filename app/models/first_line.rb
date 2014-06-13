class FirstLine < ActiveRecord::Base
  attr_accessible :book_id, :true_line, :text, :user_id, :state
  
  belongs_to :book
  belongs_to :user
  has_many :line_choices
  belongs_to :introductory_contents
  has_many :first_lines_rounds
  has_many :rounds, through: :first_lines_rounds

  validates :true_line, :inclusion => {:in => [true, false]}
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



end
