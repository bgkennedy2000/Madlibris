class DropTableGamesUsers < ActiveRecord::Migration
  def up
    drop_table 'games_users'
  end

  def down
    create_table "games_users", :force => true do |t|
      t.integer "game_id"
      t.integer "user_id"
    end  
  end
end
