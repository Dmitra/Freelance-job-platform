class CreatePermissions < ActiveRecord::Migration
  def self.up
    create_table :permissions, :id => false do |t|  #there is no need in id column as we have another primary key as composite
      t.references  :role, :user, :null => false
      t.timestamps
    end
    add_index :permissions, [:role_id, :user_id], :unique => true
  end

  def self.down
    drop_table :permissions
  end
end
