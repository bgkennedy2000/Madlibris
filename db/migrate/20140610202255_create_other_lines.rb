class CreateOtherLines < ActiveRecord::Migration
  def change
    create_table :other_lines do |t|
      t.string :kind
      t.text :text

      t.timestamps
    end
  end
end
