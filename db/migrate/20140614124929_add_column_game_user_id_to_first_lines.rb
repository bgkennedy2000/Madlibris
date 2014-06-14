class AddColumnGameUserIdToFirstLines < ActiveRecord::Migration
  def change
    add_column :first_lines, :game_user_id, :integer
  end
end
