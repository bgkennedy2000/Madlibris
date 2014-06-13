class AddColumnGamesUsersIdToLineChoice < ActiveRecord::Migration
  def change
    add_column :line_choices, :games_user_id, :integer
  end
end
