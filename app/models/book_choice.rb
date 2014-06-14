class BookChoice < ActiveRecord::Base
  attr_accessible :book_id, :round_id, :state, :games_user_id

  validates :round_id, presence: true
  validates :round_id, uniqueness: true
  validates :games_user_id, presence: true
  validates :round_id, uniqueness: true

  belongs_to :round
  belongs_to :book
  belongs_to :games_user
  has_one :user, through: :games_user

  include AASM

  aasm :column => 'state' do
    state :pending, :initial => true
    state :completed

    event :complete do
      after do
        self.save
      end
      transitions :from => :pending, :to => :completed
    end
  end



end
