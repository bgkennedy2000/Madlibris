class AddColumnIntroductoryContentsIdToFirstLines < ActiveRecord::Migration
  def change
    add_column :first_lines, :introductory_content_id, :integer
  end
end
