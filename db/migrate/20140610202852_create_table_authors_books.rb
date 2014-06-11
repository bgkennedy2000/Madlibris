class CreateTableAuthorsBooks < ActiveRecord::Migration
  def up
    create_table(:authors_books) do |t|
      t.integer :author_id              
      t.integer :book_id
    end
  end

  def down
    drop_table :authors_books
  end
end
