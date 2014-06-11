class RemoveFirstLineIdFromIntrodcutoryContent < ActiveRecord::Migration
  def up
    remove_column :introductory_contents, :first_line_id
  end

  def down
    add_column :introductory_contents, :first_line_id, :integer
  end
end
