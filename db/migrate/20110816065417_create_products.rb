class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.references :user

      t.string :name
      t.text :description
      t.float :regular_price
      t.float :target_price

      t.timestamps
    end
    add_column :products, :image, :string
    add_column :products, :quantity, :integer
    add_column :products, :is_live, :boolean, :default => 1
  end

  def self.down
    drop_table :products
  end
end
