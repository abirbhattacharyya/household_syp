class Product < ActiveRecord::Base
  belongs_to :user
  has_many :offers, :dependent => :destroy
  has_many :payments, :through => :offers
  
  attr_accessor :image_remote_url

#  file_column :image, :magick => {:versions => { "medium" => "215x290>" }}
  file_column :image
  validates_file_format_of :image, :in => ["gif", "png", "jpg", "bmp"], :message => "Hey, Upload a JPEG, GIF, or PNG image please!"

  validates_presence_of :name, :message => "Hey, name can't be blank"
  validates_presence_of :description, :message => "Hey, description can't be blank"
  validates_presence_of :regular_price, :message => "Hey, price can't be blank"
  validates_presence_of :target_price, :message => "Hey, minimum price can't be blank"
  validates_presence_of :image, :message => "Hey, image can't be blank"

  validates_uniqueness_of :name, :scope => [:user_id, :regular_price, :is_live], :message => "Hey, name already been taken"

  validate :valid_price?
  
  before_validation :download_remote_image, :if => :image_url_provided?

  CATEGORY = {
    :say_your_price => 0,
    :make_your_deal => 1
  }
  
  def self.options_for_category
    options = {}
    CATEGORY.each do |category, value|
      options[category.to_s.titleize] = value
    end
    return options.sort_by {|key, value| value}
  end

  def color
    self.color_description.gsub(/\d+/, '').strip
  end

  def reg_price
    (self.regular_price.to_f)
  end

  def min_price
    (self.regular_price.to_f*0.3)
  end

  def sold_qty
    return self.payments.map{|p| p.quantity}.sum
  end

  def stock_available?
    return true if self.quantity.to_i == 0
    stock =  self.quantity - self.sold_qty
    stock > 0 ? true : false
  end

  def stock_available
    return "Unlimited" if self.quantity.to_i == 0
    stock =  self.quantity - self.sold_qty
    return stock
  end

  private
  def valid_price?
    if self.regular_price and self.target_price
      self.errors.add(:quantity, "Hey, quantity should be greater than 0") if self.quantity and self.quantity <= 0
      self.errors.add(:regular_price, "Hey, price should be greater than 0") if self.regular_price <= 0 or self.target_price <= 0
      self.errors.add(:target_price, "Hey, target price should be less than regular price") if self.regular_price < self.target_price
    end
  end
  
  def image_url_provided?
    !self.image_remote_url.blank?
  end

  def download_remote_image
    self.image = do_download_remote_image
    #self.image_remote_url = image_url
  end

  def do_download_remote_image
    io = open(URI.parse(image_remote_url))
    def io.original_filename; base_uri.path.split('/').last; end
    io.original_filename.blank? ? nil : io
  rescue # catch url errors with validations instead of exceptions (Errno::ENOENT, OpenURI::HTTPError, etc...)
    
  end
end
