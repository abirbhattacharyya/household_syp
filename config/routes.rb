ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  map.root :controller => "home"
  map.biz '/biz', :controller => 'users', :action => 'biz'
  map.logout '/logout', :controller => 'users', :action => 'destroy'
  map.forgot '/forgot', :controller => 'users', :action => 'forgot'

  map.profile '/profile', :controller => 'users', :action => 'profile'

  map.resources :products, :only => [:index, :new]
  map.payments '/payment/:id', :controller => 'products', :action => 'payments'

  map.success '/success', :controller => 'products', :action => 'success'
  map.cancel '/cancel', :controller => 'products', :action => 'cancel'
  
  map.analytics '/analytics', :controller => 'home', :action => 'analytics'
  map.notifications '/notifications', :controller => 'home', :action => 'notifications'
  
  map.say_your_price '/sayprice/:category', :controller => 'home', :action => 'say_your_price'
  map.winners '/winners', :controller => 'home', :action => 'winners'
  map.search '/search', :controller => 'home', :action => 'search'

  map.faqs '/faqs', :controller => 'home', :action => 'faqs'
  
  map.capsule '/:id', :controller => 'products', :action => 'show'

  map.download_pdf '/download_pdf/:id', :controller => 'products', :action => 'download_pdf'

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
