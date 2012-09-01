class UserMailer < ActionMailer::Base
  default_url_options[:host] = "www.dealkat.com"
  SENDER = "\"Dealkat\" <info@dealkat.com>"

	def add_product_notification(product,email)
		subject    ' Product added on household syp'
	    recipients email
	    from       SENDER
	    body       :product => product
	    sent_on   Time.now	    
	    content_type 'text/html'
	end
end
