class AddIntroductoryContentIdToOtherLines < ActiveRecord::Migration
  def change
    add_column :other_lines, :introductory_content_id, :integer
  end
end
