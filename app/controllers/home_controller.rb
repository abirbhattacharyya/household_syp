class HomeController < ApplicationController
  before_filter :check_login, :only => [:notifications, :analytics, :daily_report]

  def index
    flash.discard
    if logged_in?
      if current_user.profile.nil?
        render :template => "users/profile"
      elsif current_user.products.empty?
        render :template => "products/new"
      else
        @notifications = [["profile", current_user.profile.created_at], ["products", current_user.products.last.created_at]]
        @last_action_on = @notifications.sort{|n1, n2| n2[1] <=> n1[1]}.first[1]
        #@notifications.sort!{|n1, n2| n2[1] <=> n1[1]}
        render :template => "/home/notifications"
      end
#    else
#      render :template => "users/biz"
    end
  end

  def notifications
    @notifications = [["profile", current_user.profile.created_at], ["products", current_user.products.last.created_at]]
    @last_action_on = @notifications.sort{|n1, n2| n2[1] <=> n1[1]}.first[1]
    #@notifications.sort!{|n1, n2| n2[1] <=> n1[1]}
  end

  def analytics
    @today = Date.today-1.day
    if request.post?
      @page = params[:page].to_i
    else
      @page = 1
    end
    @size = 5
    @per_page = 1
    @post_pages = (@size.to_f/@per_page).ceil;
    @page =1 if @page.to_i<=0 or @page.to_i > @post_pages
    @titleX = "Time Period"
    @titleY = "#"
    @colors = []
    @i = 0
    @head_line = ""

    case @page
      when @i+=1
        @head_line = "Look at your cool analytics!"
        @title = "# Of Visits"
        @offers_a = Offer.first(:select => "SUM(counter) as total", :joins => "INNER JOIN products ON offers.product_id=products.id and products.user_id = #{current_user.id} and response NOT LIKE 'expired'")
        @offers_y = Offer.first(:select => "SUM(counter) as total", :joins => "INNER JOIN products ON offers.product_id=products.id and products.user_id = #{current_user.id} and response NOT LIKE 'expired' and Date(offers.updated_at) = '#{Date.today}'")
        @chart_data1 = [["Today", @offers_y.total.to_i], ["Cumulative", @offers_a.total.to_i]]
      when @i+=1
        @head_line = "Even more useful data to measure!"
        @title = "# Of Negotiations"
        @offers_a = Offer.first(:select => "SUM(counter) as total", :joins => "INNER JOIN products ON offers.product_id=products.id and products.user_id = #{current_user.id} and response NOT LIKE 'expired'")
        @offers_y = Offer.first(:select => "SUM(counter) as total", :joins => "INNER JOIN products ON offers.product_id=products.id and products.user_id = #{current_user.id} and response NOT LIKE 'expired' and Date(offers.updated_at) = '#{Date.today}'")
        @chart_data1 = [["Today", @offers_y.total.to_i], ["Cumulative", @offers_a.total.to_i]]
      when @i+=1
        @head_line = "Track Purchases in Real-Time"
        @title = "# Of Purchases"
        @offers_a = Offer.first(:select => "COUNT(counter) as total", :joins => "INNER JOIN products ON offers.product_id=products.id and products.user_id = #{current_user.id} and response LIKE 'paid'")
        @offers_y = Offer.first(:select => "COUNT(counter) as total", :joins => "INNER JOIN products ON offers.product_id=products.id and products.user_id = #{current_user.id} and response LIKE 'paid' and Date(offers.updated_at) = '#{Date.today}'")
        @chart_data1 = [["Today", @offers_y.total.to_i], ["Cumulative", @offers_a.total.to_i]]
      when @i+=1
        @head_line = "Watch your dynamic pricing dollars"
        @title = "Dollars Total Purchases"
        @offers_a = Offer.first(:select => "SUM(price) as total", :joins => "INNER JOIN products ON offers.product_id=products.id and products.user_id = #{current_user.id} and response LIKE 'paid'")
        @offers_y = Offer.first(:select => "SUM(price) as total", :joins => "INNER JOIN products ON offers.product_id=products.id and products.user_id = #{current_user.id} and response LIKE 'paid' and Date(offers.updated_at) = '#{Date.today}'")
        @chart_data1 = [["Today", @offers_y.total.to_i], ["Cumulative", @offers_a.total.to_i]]
      when @i+=1
        @head_line = "Algorithms manage your margins in real-time!"
        @title = "Dollars Total Discount"
        @offers_a = Offer.first(:select => "SUM(products.regular_price-price) as total", :joins => "INNER JOIN products ON offers.product_id=products.id and products.user_id = #{current_user.id} and response LIKE 'paid'")
        @offers_y = Offer.first(:select => "SUM(products.regular_price-price) as total", :joins => "INNER JOIN products ON offers.product_id=products.id and products.user_id = #{current_user.id} and response LIKE 'paid' and Date(offers.updated_at) = '#{Date.today}'")
        @chart_data1 = [["Today", @offers_y.total.to_i], ["Cumulative", @offers_a.total.to_i]]
      else
        @title = "# Of Negotiations"
        @offers_a = Offer.first(:select => "SUM(counter) as total", :joins => "INNER JOIN products ON offers.product_id=products.id and products.user_id = #{current_user.id}")
        @offers_y = Offer.first(:select => "SUM(counter) as total", :joins => "INNER JOIN products ON offers.product_id=products.id and products.user_id = #{current_user.id} and Date(offers.updated_at) = '#{Date.today}'")
        @chart_data1 = [["Today", @offers_y.total.to_i], ["Cumulative", @offers_a.total.to_i]]
    end
  end
  
  def say_your_price
    if logged_in?
      redirect_to root_path
      return
    end
    if request.post?
      @page = params[:page].to_i
    else
      @page = 1
    end
    category = params[:category]
    @size = Product.all(:conditions => ["category=?", category]).count.to_i
    @per_page = 1
    @post_pages = (@size.to_f/@per_page).ceil;
    @page =1 if @page.to_i<=0 or @page.to_i > @post_pages
    @products = Product.all(:conditions => ["category=?", category], :limit => "#{@per_page*(@page - 1)}, #{@per_page}")

    @page_start_num = ((@page - 4) > 0) ? (@page - 4) : 1
    @page_end_num = ((@page_start_num + 8) > @post_pages) ? @post_pages : (@page_start_num + 8)
    @page_start_num = ((@post_pages - @page_end_num) < 8) ? (@page_end_num - 8) : @page_start_num
    @page_start_num = 1 if @page_start_num < 1
  end
  
  def winners
    @payments = Payment.all(:order => "id desc",:include => [:offer], :limit => 100)
    #@payments = Payment.all(:order => "id desc", :joins => "INNER JOIN offers ON payments.offer_id=offers.id", :limit => 100)
  end

end
