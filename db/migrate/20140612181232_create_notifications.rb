class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :subject
      t.integer :user_id
      t.boolean :checked

      t.timestamps
    end
  end
end
