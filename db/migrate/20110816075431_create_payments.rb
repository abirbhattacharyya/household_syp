class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.integer :offer_id
      t.integer :quantity, :default => 1
      t.string :voucher_code

      t.timestamps
    end
    add_column :payments, :transaction_id, :string
    add_column :payments,:email, :string
    add_column :payments,:price,:float
    add_column :payments,:first_name,:string
    add_column :payments,:last_name,:string
    add_column :payments,:street1,:string
    add_column :payments,:street2,:string
    add_column :payments,:city,:string
    add_column :payments,:state,:string
    add_column :payments,:country,:string
    add_column :payments,:postal_code,:string
  end

  def self.down
    drop_table :payments
  end
end
