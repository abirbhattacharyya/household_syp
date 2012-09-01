class ProductsController < ApplicationController
#  before_filter :check_login, :except => [:show, :download_pdf, :send_to, :payments, :success, :cancel]
  
  def index
    @products = current_user.products
  end
  
  def update
    id = params[:id]
    redirect_to "/" and return if id.nil?
    @product = Product.find_by_id(id)
    redirect_to "/" and return if @product.nil?
    if request.post?
      @product.attributes = params[:product]
      if @product.save
        redirect_to :action => :index
      else
        flash[:error] = @product.errors.first[1]
      end
    end
  end

  def new
    if request.post?
      @product = Product.new(params[:product])
      if @product.valid? and @product.errors.empty?
        @product.user = current_user
        @product.quantity = params[:product][:quantity].gsub(/\D+/, "") if params[:product][:quantity]
        @product.regular_price = params[:product][:regular_price].gsub(/\D+/, "")
        @product.target_price = params[:product][:target_price].gsub(/\D+/, "")
        if @product.save
          
          flash[:notice] = "Your product is at #{capsule_url(@product.id)}"

          UserMailer.deliver_add_product_notification(@product,current_user,email)
          @product = nil
          if params[:submit_button].strip.downcase.eql? "finish"
            redirect_to root_path
          end
        else
          flash[:error] = @product.errors.first[1]
        end
      else
        flash[:error] = @product.errors.first[1]
      end
    end
  end

  def payments
    if request.post?
      if params[:payment]
        @payment = Payment.find(params[:id])
        if @payment.update_attributes(params[:payment])
          Notification.deliver_sendcoupon(@payment.email, @payment)
          flash[:notice] = "Thank you for playing! You will get your voucher soon!"
          redirect_to say_your_price_path(Product::CATEGORY[:make_your_deal])
          return
        else
          @payment.email = nil
          flash[:error]= "Hi, please enter a valid email address"
          render :template => "/products/success"
          return
        end
      else
        @offer = Offer.find_by_id(params[:id].to_i)
        if @offer.nil?
          redirect_to root_path
          return
#        else
#          @payment = @offer.payment || Payment.new
#          render :template => "/products/success"
        end
      end
      @payment = @offer.payment || Payment.new
      @payment.offer = @offer
      @code = rand_code(12)
      while(1)
        if Payment.find_by_voucher_code(@code)
          @code = rand_code(12)
        else
          break;
        end
      end
      @payment.price = @offer.price
      @payment.voucher_code = @code
      if @payment.valid?
        @payment.save
        @offer.update_attribute(:response, "paid")
        if @offer.product.category == Product::CATEGORY[:make_your_deal]
          Offer.create(:ip => @offer.ip, :product_id => @offer.product_id, :token => @offer.token, :response => "counter", :price => @offer.product.regular_price, :counter => 1)
        end
        flash[:notice] = "Hey, thanks for playing and your payment!"
        render :template => "/products/success"
      end
    else
      redirect_to root_path
    end
  end

  def download_pdf
    if params[:id]
      @payment = Payment.find_by_id(params[:id])
      if @payment.nil?
        redirect_to root_path
        return
      end
      output= render_to_string :partial => "partials/pdf_letter", :object => @payment
      pdf = PDF::Writer.new
      pdf.add_image_from_file("#{Rails.root}/public/images/mylogo.jpg", 35, 730, 35, 35)
      pdf.text output
      send_data pdf.render, :filename => "mypricevoucher.pdf", :type => "application/pdf"
    else
      redirect_to root_path
    end
  end
  
  def success
    if params[:token]
      response = EXPRESS_GATEWAY.purchase(params[:amount].to_i,:token => params[:token], :payer_id => params[:PayerID])

      if response.success?
        trans_id = response.params['transaction_id']
        amount = (response.params['gross_amount'].to_f)

        if amount > 0
          save_payer_details(params[:token],params[:offer_id],amount,params[:quantity],trans_id)
          @payment = Payment.find_by_transaction_id(trans_id)
          @code = rand_code(12)
          while(1)
            if Payment.find_by_voucher_code(@code)
              @code = rand_code(12)
            else
              break;
            end
          end
          @payment.update_attributes(:voucher_code => @code)
          @payment.offer.update_attribute(:response, "paid")
          flash[:notice] = "Thanks for payment"
          Notification.deliver_payment_to_consumer(@payment.id)
          Notification.deliver_payment_to_merchant(@payment.id)
          payment_to_merchant(@payment.id)
        else
          flash[:notice] = "Something went wrong in payment"
          redirect_to root_path
        end
      else
          flash[:notice] = "Something went wrong in payment"
          redirect_to root_path
      end
    else
      redirect_to root_path
    end
  end

  def cancel
    flash[:notice] = "Payment has been canceled"
    redirect_to root_path
  end
  
  def show
    if params[:id]
      @product = Product.find_by_id(params[:id])
      if @product.nil?
        redirect_to root_path
        return
      end
      offer_token = (session[:_csrf_token] ||= ActiveSupport::SecureRandom.base64(32))

      @last_offer = @product.offers.last(:conditions => ["ip = ? and token = ?", request.remote_ip, offer_token])
      if request.post?
        if @last_offer and @last_offer.accepted?
          return
        end
        if params[:submit_button]
          submit = params[:submit_button].strip.downcase
          if ["yes", "no"].include? submit
            if submit == "no"
              if @product.category == Product::CATEGORY[:make_your_deal]
                if @last_offer.last?
                  @last_offer.update_attributes({:price => @product.regular_price, :response => "counter", :counter => 1})
                  flash[:error] = "Sorry we can't make a deal right now. Try again later?"
                else
                  if((rand(999)%2) == 1)
                    @last_offer.update_attribute(:response, "rejected")
                    @product.offers.create(:ip => request.remote_ip, :token => offer_token, :response => "counter", :price => @last_offer.price, :counter => 1)
                    flash[:notice] = "Hey, tell us a number & we can play"
                  else
                    price = (@last_offer.price*0.99).floor
                    if price >= @product.min_price
                      @last_offer.update_attributes({:price => price, :counter => @last_offer.counter+1})
                      flash[:notice] = "Ok, here's a little something for your thoughts"
                    end
                  end
                end
              else
                @last_offer.update_attribute(:response, "rejected")
                flash[:error] = "Sorry we can't make a deal right now. Try again later?"
              end
            elsif submit == "yes"
              @last_offer.update_attribute(:response, "accepted")
              flash[:notice] = (@last_offer.price == 0) ? "Cool! Congrats! you won free Dealkat khakis. Share with facebook /twitter friends!" : "Cool, come on down to the store!"
            end
            for offer in @product.offers.all(:conditions => ["ip = ? and token = ? and id < ? and (response IS NULL OR response LIKE 'counter')", request.remote_ip, offer_token, @last_offer.id])
              offer.update_attribute(:response, "expired") unless ["paid", "accepted", "rejected"].include? offer.response
            end
            return
          end
        end
        price = params[:price].to_f.ceil
        
        if price <= 0
            flash[:error] = "Hi, please enter a non-zero number and we can play"
        else
          if @last_offer and @last_offer.counter?
            @offer = @product.offers.last(:conditions => ["ip = ? and token = ? and response IS NULL", request.remote_ip, offer_token])
            if @offer.nil? and @product.category == Product::CATEGORY[:make_your_deal]
              offer = @product.offers.create(@last_offer.attributes)
              @last_offer.update_attributes({:price => (price-1), :response => nil})
              @offer = @last_offer
              @last_offer = offer
              if(price <= @product.min_price)
                @new_offer = with_precision((@product.reg_price.to_f*0.95), :precision => 2).to_f.ceil
                @last_offer.update_attributes(:price => @new_offer, :response => "last", :counter => @last_offer.counter+1)
                flash[:notice] = "Hi, $#{price} is too low. How about $#{@new_offer}?"
                return
              end
            end
            if @offer
                if price >= @last_offer.price
                  @last_offer.update_attribute(:response, "accepted")
                  flash[:notice] = "Cool, come on down to the store!"
                  return
                end
                if(price > @offer.price)
                    @offer.update_attributes(:price => price, :counter => (@offer.counter + 1))
                    max_per = ((@last_offer.price*100)/@product.reg_price).to_i
                    rand_per = (max_per > 50 ? ((rand(999)%(max_per-50)) + 50) : max_per)
                    @new_offer = with_precision((@product.reg_price.to_f*(rand_per.to_f/100)), :precision => 2).to_f.ceil

                    if @new_offer.to_f >= @last_offer.price
                      @last_offer.update_attributes(:response => "last")
                    elsif @new_offer.to_f <= @offer.price
                      @product.offers.update_all("response='expired'", ["ip = ? and token = ? and id <= ? and (response IS NULL OR response LIKE 'counter')", request.remote_ip, offer_token, @last_offer.id])
                      @last_offer.update_attributes(:price => @offer.price, :response => "accepted")
                    elsif @new_offer == with_precision(@product.target_price, :precision => 2).to_f.ceil
                      @last_offer.update_attributes(:price => @new_offer, :counter => (@last_offer.counter + 1), :response => "last")
                    else
                      if((rand(999)%2) == 1)
                        @last_offer.update_attributes(:price => @new_offer, :counter => (@last_offer.counter + 1))
                      else
                        @last_offer.update_attributes(:price => @new_offer, :counter => (@last_offer.counter + 1), :response => "last")
                      end
                    end
                else
                    flash[:notice] = "Hey, please enter an offer greater than the last one!"
                    return
                end
            else
              return
            end
          else
              @offer = @product.offers.create(:ip => request.remote_ip, :token => offer_token, :price => price, :counter => 1)
              @last_offer = @offer
              
#              @last_offer = @product.offers.last(:conditions => ["ip = ? and token = ?", request.remote_ip, offer_token])
              
              if(price <= @product.min_price)
                  @new_offer = with_precision((@product.reg_price.to_f*0.95), :precision => 2).to_f.ceil
                  Offer.create(:ip => request.remote_ip, :token => offer_token, :product_id => @product.id, :price => @new_offer, :response => "last", :counter => 1)
                  flash[:notice] = "Hi, $#{price} is too low. How about $#{@new_offer}?"
              elsif(price >= @product.reg_price.to_f*0.95)
                  @new_offer = with_precision((@product.reg_price.to_f*0.95), :precision => 2).to_f.ceil
                  Offer.create(:ip => request.remote_ip, :token => offer_token, :product_id => @product.id, :price => @new_offer, :response => "counter", :counter => 1)
                  @counter_offer = @product.offers.last(:conditions => ["ip = ? and token =? and response = ?", request.remote_ip, offer_token, 'counter'])
                  for offer in @product.offers.all(:conditions => ["ip = ? and token = ? and id <= ? and (response IS NULL OR response LIKE 'counter')", request.remote_ip, offer_token, @offer.id])
                    offer.update_attribute(:response, "expired") unless ["paid", "accepted", "rejected"].include? offer.response
                  end
                  @counter_offer.update_attribute(:response, "accepted")
                  if price >= @product.reg_price
                    flash[:notice] = "Hey, don't overspend. Yours for only $#{@new_offer}"
                  else
                    flash[:notice] = "Cool, come on down to the store!"
                  end
              else
                  price_per = ((price*100)/@product.reg_price.to_f).ceil
                  price_per = ((price_per < 50) ? 50 : price_per)
                  rand_per = ((price_per < 95) ? ((rand(999)%(95-price_per)) + price_per) : 95)
                  @new_offer = with_precision((@product.reg_price.to_f*(rand_per.to_f/100)), :precision => 2).to_f.ceil
                  if @new_offer == with_precision(@product.target_price, :precision => 2).to_f.ceil
                    Offer.create(:ip => request.remote_ip, :token => offer_token, :product_id => @product.id, :price => @new_offer, :response => "last", :counter => 1)
                    flash[:notice] = "Hey, the best we can do is $#{@new_offer}. Deal?"
                  elsif price >= @new_offer.to_f
                    Offer.create(:ip => request.remote_ip, :token => offer_token, :product_id => @product.id, :price => @new_offer, :response => "last", :counter => 1)
                    flash[:notice] = "Hey, the best we can do is $#{@new_offer}. Deal?"
                  else
                    Offer.create(:ip => request.remote_ip, :token => offer_token, :product_id => @product.id, :price => @new_offer, :response => "counter", :counter => 1)
                    flash[:notice] = "Hi, we can do $#{@new_offer}. Deal?"
                  end
              end
              return
          end
          @last_offer = @product.offers.last(:conditions => ["ip = ? and token = ?", request.remote_ip, offer_token])
          if @last_offer.last?
            flash[:notice] = "Hey, the best we can do is $#{@last_offer.price}. Deal?"
          elsif @last_offer.accepted?
            flash[:notice] = "Cool, come on down to the store!"
          else
            flash[:notice] = "Hi, we can do #{(@last_offer.price > 0) ? "$#{@last_offer.price}" : "Free of cost"}. Deal?"
          end
          return
        end
      end
    end
  end

end
