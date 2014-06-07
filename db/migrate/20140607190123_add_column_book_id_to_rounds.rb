class AddColumnBookIdToRounds < ActiveRecord::Migration
  def change
    add_column :rounds, :book_id, :integer
  end
end
