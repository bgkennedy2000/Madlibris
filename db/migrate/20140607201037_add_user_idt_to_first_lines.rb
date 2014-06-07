class AddUserIdtToFirstLines < ActiveRecord::Migration
  def change
    add_column :first_lines, :user_id, :integer
  end
end
