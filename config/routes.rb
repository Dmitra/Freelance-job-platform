ActionController::Routing::Routes.draw do |map|
  map.signup          'signup',            :controller => 'users',     :action => 'new'
  map.login           'login',             :controller => 'sessions',  :action => 'new'
  map.logout          'logout',            :controller => 'sessions',  :action => 'destroy'
  map.activate        'activate/:id',      :controller => 'accounts',  :action => 'show'
  map.forgot_password 'forgot_password',   :controller => 'passwords', :action => 'new'
  map.reset_password  'reset_password/:id',:controller => 'passwords', :action => 'edit'
  map.change_password 'change_password',   :controller => 'accounts',  :action => 'edit'
 
  map.resources :users, :collection => {:disable => :delete, :enable => :put} do |users|
    users.resource  :account
    users.resources :roles
  end
  map.with_options :controller => 'contributorships' do |contributor|
    contributor.contributors           'contributors',                                        :action => 'index'
    contributor.create_contributor     'contributorship/create/user/:user_id',                :action => 'create'
    contributor.create_contributorship 'contributorship/create/user/:user_id/order/:order_id',:action => 'create'
    contributor.delete_contributorship 'contributorship/:id/delete',                          :action => 'destroy'
  end

  map.show_user       'user/:login',    :controller => 'users', :action => 'show_private'
  
  map.resources :mailbox, :collection => { :trash => :get }
  map.resources :messages, :member => { :reply => :get, :forward => :get, :reply_all => :get, :undelete => :put }
  map.resources :sent  
  
  map.resource :session
  map.resource :password
  map.inbox 'inbox', :controller => "mailbox", :action => "index"

  map.with_options :controller => 'orders' do |order|
    order.connect         'orders/archive/:year/:month/:day', :month => nil, :day => nil, :requirements => { :year => /\d{4}/ }
    order.my_orders       'orders/my',                    :action => 'my'
    order.edit_watchlist  'orders/watchlist',             :action => 'edit_watchlist'
    order.edit_drafts     'orders/drafts',                :action => 'edit_drafts'
    order.user_orders     'orders/user/:owner',           :action => 'user'
    order.cost_summary    'orders/cost_summary',	      :action => 'cost_summary'
    order.destroy_all     'order/destroy_all',            :action => 'destroy'
    order.publish         'order/:id/publish',            :action => 'publish'
    order.bill            'order/:id/bill',               :action => 'bill'
    order.finish          'order/:id/finish',             :action => 'finish'
    order.watch_all       'order_watch_all',              :action => 'watch'
    order.watch           'order/:id/watch',              :action => 'watch'
  end
  
  map.with_options :controller => 'solutions' do |solution|
    solution.solutions        'user/:user_id/solutions'
    solution.evaluate         'order/:order_id/solution/:id/evaluate/:rating', :action => 'evaluate'
    solution.operate          'order/:order_id/solution/:id/operate', :action => 'operate'
  end
  map.resources :orders do |orders|
    orders.resources :solutions do |solutions|
      solutions.resources :comments
    end
    orders.resources :comments
  end
  
  map.add_finance   'finance/add',                                    :controller => 'finance', :action => 'add'
  map.new_reply     'order/:order_id/solution/:solution_id/reply/new',:controller => 'replies', :action => 'new'
  map.create_reply  'order/:order_id/solution/:solution_id/reply',    :controller => 'replies', :action => 'create'
  map.resource :asset
      
  map.root :orders

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
#  map.connect 'selenium'
#  map.connect '*path', :controller => 'redirect', :action => 'index'
end
