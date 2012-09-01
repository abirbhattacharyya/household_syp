class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.references :user
      
      t.string :name
      t.string :address
      t.string :phone
      t.string :email
      t.string :twitter
      t.string :facebook_url
      t.string :company_url
      t.string :logo_url
      t.string :header_color
      t.string :home_page_image1
      t.string :home_page_image2
      t.string :home_page_image3

      t.timestamps
    end
  end

  def self.down
    drop_table :profiles
  end
end
