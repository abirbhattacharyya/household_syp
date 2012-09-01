class Profile < ActiveRecord::Base
  belongs_to :user

  file_column :logo_url, :magick => {:versions => { "thumb" => "90x85>" }}
  file_column :home_page_image1, :magick => {:versions => { "normal" => "300x460>" }}
  file_column :home_page_image2, :magick => {:versions => { "normal" => "300x460>" }}
  file_column :home_page_image3, :magick => {:versions => { "normal" => "300x460>" }}
  validates_presence_of :name, :address, :phone, :twitter, :facebook_url, :company_url
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => "^Hey, incorrect email"

  validates_file_format_of :logo_url, :in => ["jpg", "jpeg"], :message => "Hey, Upload a JPEG image please!"
  validates_file_format_of :home_page_image1, :in => ["jpg", "jpeg"], :message => "Hey, Upload a JPEG image please!"
  validates_file_format_of :home_page_image2, :in => ["jpg", "jpeg"], :message => "Hey, Upload a JPEG image please!"
  validates_file_format_of :home_page_image3, :in => ["jpg", "jpeg"], :message => "Hey, Upload a JPEG image please!"

  def twitter_url
    if self.twitter
      "http://twitter.com/" + self.twitter
    end
  end
end
