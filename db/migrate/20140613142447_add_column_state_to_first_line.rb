class AddColumnStateToFirstLine < ActiveRecord::Migration
  def change
    add_column :first_lines, :state, :string
  end
end
