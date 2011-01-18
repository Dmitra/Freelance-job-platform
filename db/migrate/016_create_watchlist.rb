class CreateWatchlist < ActiveRecord::Migration
  def self.up
    create_table :watchlist, :id => false do |t|
      t.integer     :watcher, :null => false
      t.references  :order, :null => false
    end
    add_index :watchlist, [:watcher, :order_id], :unique => true
  end

  def self.down
    drop_table :watchlist
  end
end
