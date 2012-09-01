class Payment < ActiveRecord::Base
  belongs_to :offer,:include => [:product]

  validates_format_of :email, :if => :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => "^Hey, please enter valid email"

  validate :valid_info
  attr_accessor :cc_expiry_m1, :cc_expiry_m2, :payment_option

  def new_expiry_date
    @dates = ["2011-03-31", (self.created_at + 2.week), (self.created_at + 1.week)]
    return @dates[rand(99)%@dates.size]
  end

  def valid_info
    if self.transaction_id
      self.errors.add_to_base("Hey, transaction id can't be blank") if self.transaction_id.nil?
    end
  end
end
