class CreateCategorizations < ActiveRecord::Migration
  def self.up
    create_table :categorizations, :id => false do |t|
      t.references  :order, :category, :null => false
    end
    add_index :categorizations, [:order_id, :category_id], :unique => true
  end

  def self.down
    drop_table :categorizations
  end
end
