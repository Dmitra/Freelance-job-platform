class CreateFinance < ActiveRecord::Migration
  def self.up
    create_table :finances do |t|
      t.integer :user_id,   :null => false
      t.string  :paypal,    :null => false
      t.integer :quantity,  :default => 0   #money are stored in cents
      t.timestamps
    end
  end

  def self.down
    drop_table :finances
  end
end