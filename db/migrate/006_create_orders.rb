class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.references  :user,            :null => false
      t.string      :name
      t.text        :description
      t.integer     :solutions_count, :default => 0, :null => false
      t.integer     :cost,            :null => false
      t.integer     :term,            :null => false #days after created_at
      t.enum        :workflow_state,  :limit => Order.states, :default => Order::STATUS::DRAFT
      t.enum        :privacy,         :limit => Order::PRIVACY.constants, :default => Order::PRIVACY::OPEN
      t.boolean     :font,            :default => false
      t.boolean     :color,           :default => false
      t.integer     :views,           :default => 0 #quantity of views by visitors
      t.timestamps
    end
    add_index     :orders, :user_id
  end

  def self.down
    drop_table  :orders
  end
end
