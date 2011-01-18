class CreateSolutions < ActiveRecord::Migration
  def self.up
    create_table :solutions do |t|
      t.references :user, :order, :null => false
      t.text    :body
      t.text    :description
      t.binary  :attachments    #limit to 10Mb?
      t.enum    :workflow_state,  :limit => Solution.states, :default => Solution::STATUS::NEW
      t.integer :rating,          :default => 0
      t.integer :comments_count,  :null => false, :default => 0
      t.timestamps
    end
    add_index :solutions, :order_id
    add_index :solutions, :user_id
  end

  def self.down
    drop_table :solutions
  end
end
