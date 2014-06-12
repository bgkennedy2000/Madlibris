class CreateGamesUsers < ActiveRecord::Migration
  def change
    create_table :games_users do |t|
      t.integer :game_id
      t.integer :user_id
      t.string :invitation_status
      t.string :user_role

      t.timestamps
    end
  end
end
