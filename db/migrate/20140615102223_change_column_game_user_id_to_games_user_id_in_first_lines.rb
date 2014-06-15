class ChangeColumnGameUserIdToGamesUserIdInFirstLines < ActiveRecord::Migration
  def up
    rename_column :first_lines, :game_user_id, :games_user_id
  end

  def down
    rename_column :first_lines, :games_user_id, :game_user_id
  end
end
