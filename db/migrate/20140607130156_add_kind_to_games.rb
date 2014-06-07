class AddKindToGames < ActiveRecord::Migration
  def change
    add_column :games, :kind, :string
  end
end
