class CreateFirstLines < ActiveRecord::Migration
  def change
    create_table :first_lines do |t|
      t.string :text
      t.integer :book_id
      t.boolean :true_line

      t.timestamps
    end
  end
end
