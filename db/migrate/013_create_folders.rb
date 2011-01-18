class CreateFolders < ActiveRecord::Migration
  def self.up
    create_table :folders do |t|
      t.integer :user_id
      t.integer :parent_id, :position, :children_count, :ancestors_count, :descendants_count
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :folders
  end
end
