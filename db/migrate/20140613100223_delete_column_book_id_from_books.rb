class DeleteColumnBookIdFromBooks < ActiveRecord::Migration
  def up
    remove_column :rounds, :book_id
  end

  def down
    add_column :rounds, :book_id, :integer
  end
end
