class CreateBookChoices < ActiveRecord::Migration
  def change
    create_table :book_choices do |t|
      t.integer :user_id
      t.integer :round_id
      t.integer :book_id
      t.string :state

      t.timestamps
    end
  end
end
