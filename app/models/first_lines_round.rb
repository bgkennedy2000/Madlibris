class FirstLinesRound < ActiveRecord::Base
  attr_accessible :first_line_id, :round_id

  belongs_to :round
  belongs_to :first_line, dependent: :destroy
end
