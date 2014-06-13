class CreateFirstLinesRounds < ActiveRecord::Migration
  def change
    create_table :first_lines_rounds do |t|
      t.integer :first_line_id
      t.integer :round_id

      t.timestamps
    end
  end
end
