class AddPreFirstLineContentAndSourceToBooks < ActiveRecord::Migration
  def change
    add_column :books, :pre_first_line_content, :text
    add_column :books, :source, :string
  end
end
