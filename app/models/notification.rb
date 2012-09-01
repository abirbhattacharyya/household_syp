class Notification < ActionMailer::Base
  default_url_options[:host] = "dealkat.com"
  SENDER = '"sayaprice" <myprice@sayaprice.com>'

  def forgot(user)
    subject    'Your forgotten password for Dealkat'
    recipients user.email
    from       SENDER

    body       :user => user
    sent_on    Time.now
#    content_type 'text/html'
  end

  def sendcoupon(recipient, payment)
    subject    "#{payment.offer.product.user.profile.name} Say Your Price Voucher"
    #recipients recipient
    bcc recipient
    from       SENDER

    body      :payment => payment
    sent_on    Time.now
  end

  def dailyreport(recipient, todays_coupons, all_coupons, analytics_today, analytics_overall, todays_dollars, overall_dollars, today)
    subject    'daily status report'
    #recipients recipient
    bcc recipient
    from       SENDER

    body      :todays_coupons => todays_coupons, :all_coupons => all_coupons, :analytics_today => analytics_today, :analytics_overall => analytics_overall, :todays_dollars => todays_dollars, :overall_dollars => overall_dollars, :today => today
    sent_on    Time.now
  end
end
