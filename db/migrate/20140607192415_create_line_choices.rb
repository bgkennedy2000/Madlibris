class CreateLineChoices < ActiveRecord::Migration
  def change
    create_table :line_choices do |t|
      t.integer :first_line_id
      t.integer :user_id
      t.integer :round_id

      t.timestamps
    end
  end
end
