class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :description
      t.boolean :archived
      t.datetime :archived_at
      t.integer :user_id

      t.timestamps
    end
  end
end
