class CreateAssets < ActiveRecord::Migration
  def self.up
    create_table :assets do |t|
      t.string  :data_file_name
      t.string  :data_content_type
      t.integer :data_file_size
      t.integer :attachable_id
      t.enum    :attachable_type, :limit => [:User, :Order, :Solution]
      t.timestamps
    end

    add_index :assets, [:attachable_id, :attachable_type]
  end
  
  def self.down
    drop_table :assets
  end
end
