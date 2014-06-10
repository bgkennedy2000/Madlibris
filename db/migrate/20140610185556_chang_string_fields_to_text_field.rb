class ChangStringFieldsToTextField < ActiveRecord::Migration
  def up
    change_table :books do |t|
      t.change :synopsis, :text
      t.change :image_url, :text
    end
  end

  def down
    change_table :books do |t|
      t.change :synopsis, :string
      t.change :image_url, :string
    end
  end
end
