class AddColumnStateToLineChoices < ActiveRecord::Migration
  def change
    add_column :line_choices, :state, :string
  end
end
