class CreateTableGamesUser < ActiveRecord::Migration
  def up
    create_table(:games_users) do |t|
      t.integer :game_id              
      t.integer :user_id
    end
  end

  def down
    drop_table :games_users
  end
end
