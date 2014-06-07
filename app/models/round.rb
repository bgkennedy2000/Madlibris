class Round < ActiveRecord::Base
  attr_accessible :game_id, :state, :book_id
  validates :game_id, presence: true
  belongs_to :game
  belongs_to :book

  include AASM

  aasm :column => 'state' do
    state :creating, :initial => true
    state :playing
    state :completing
  end


end
