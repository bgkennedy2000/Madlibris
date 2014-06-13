class Round < ActiveRecord::Base
  attr_accessible :game_id, :state
  validates :game_id, presence: true
  belongs_to :game

  include AASM

  aasm :column => 'state' do
    state :book_choosing, :initial => true
    state :playing
    state :completed
  end


end
