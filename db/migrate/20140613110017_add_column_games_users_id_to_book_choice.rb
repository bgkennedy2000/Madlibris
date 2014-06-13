class AddColumnGamesUsersIdToBookChoice < ActiveRecord::Migration
  def change
    add_column :book_choices, :games_user_id, :integer
  end
end
