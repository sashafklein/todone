class AddDefaultToItemArchived < ActiveRecord::Migration
  def change
    change_column :items, :archived, :boolean, :default => false
  end
end
