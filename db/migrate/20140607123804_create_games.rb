class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :type
      t.string :state

      t.timestamps
    end
  end
end
