class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.belongs_to :user, index: true
      t.integer :order_num

      t.timestamps
    end
    add_index :orders, :order_num
  end
end
