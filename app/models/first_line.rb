class FirstLine < ActiveRecord::Base
  attr_accessible :book_id, :true_line, :text, :user_id
  
  belongs_to :book
  belongs_to :user
  has_many :line_choices

  validates :book_id, presence: true
  validates :text, presence: true
  validates :true_line, :inclusion => {:in => [true, false]}
  validate :fake_line_has_user?

  def fake_line_has_user?
    if self.true_line == false
      errors.add(:base, "Fake lines require a user_id") unless self.user
    end
  end

end
