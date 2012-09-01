class AddCategoryInProducts < ActiveRecord::Migration
  def self.up
    add_column :products,:category,:integer,:limit => 2,:default => 0
  end

  def self.down
    remove_column :products,:category
  end
end
