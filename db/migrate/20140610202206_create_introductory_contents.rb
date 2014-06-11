class CreateIntroductoryContents < ActiveRecord::Migration
  def change
    create_table :introductory_contents do |t|
      t.integer :book_id
      t.integer :first_line_id

      t.timestamps
    end
  end
end
