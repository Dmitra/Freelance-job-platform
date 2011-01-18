class OrdersController < ApplicationController
  before_filter :login_required, :only => [:new, :create]
  before_filter :process_params, :only => [:index, :my, :edit_watchlist, :edit_drafts, :show]
  
  def index
    @orders = Order.search(current_user, params[:status], params[:sort], params[:search])
  end
  
  def my
    @drafts = current_user.orders.search(current_user, [Order::STATUS::DRAFT],
      ( params[:sort] if params[:sort][:table] == 'drafts') )
    @orders = current_user.orders.search(current_user, Order::STATUS.constants - [Order::STATUS::DRAFT],
      ( params[:sort] if params[:sort][:table] == 'orders') )
    @solved = Order.solved_by(current_user,
      ( params[:sort] if params[:sort][:table] == 'solved') )
    @watchlist = current_user.watchlist.search(current_user, Order::STATUS.constants,
      ( params[:sort] if params[:sort][:table] == 'watchlist') )
  end
  def user
    @orders = User.find(params[:user]).orders
  end
  def new
    @order = Order.new
    @order.description = "Brief for Names/Claims"
    @order.term = 7
    @order.privacy = Order::PRIVACY::OPEN
    @order.cost = 0
    @order.categories[0] = Category.find(1)
  end
  
  def show
    @order = Order.find(params[:id])
    if @order.user != current_user
      Order.skip_timestamping do
        @order.update_attribute(:views, @order.views + 1)
      end
    end
    params[:filter] = case params[:filter]
      when 'my' then current_user.id
      when 'customer' then @order.user.id
      when 'admin' then User.find_by_login('admin').id
      else 'all'
    end
    @solutions = @order.solutions.search(current_user, params[:sort])
    @comments = @order.comments.filter(params[:filter])
    @comments_brief = Comment.brief(@order)
  end

  def edit
    @order = Order.find(params[:id])
    @comments = Comment.brief(@order)
  end

  def create
    @order = Order.new(params[:order])
    @order.user = current_user
    if @order.save
      process_file_uploads(@order)  #attachments cannot be saved unowned
      flash[:notice] = 'Order was successfully created.'
      render :action => 'show'
    else
      render :action => 'new'
    end
  end

  def update
    @order = Order.find(params[:id])
    process_file_uploads(@order)  #save attachments before order can fail save
    if @order.update_attributes params[:order]
      flash[:notice] = 'Order was successfully updated.'
      redirect_to :action => 'show'
    else
      render :action => "edit"
    end    
  end
  
  def bill
    @order = Order.find(params[:id])
  end
  
  def publish
    @order = Order.find(params[:id])
    @order.publish!(current_user)
    unless @order.save
      flash[:error] = 'U do not have enough funds on account to Pay for Order'
      redirect_to :action => 'index' and return
    end
    redirect_to :action => 'finish'
  end
  
  def finish
    @order = Order.find(params[:id])
  end

  def destroy
    @orders = params[:id] ? [Order.find(params[:id])] : Order.find(params[:order_ids])
    flash[:notice], flash[:error] = [], []
    @orders.each{|order|
      if order.cancelable_by?(current_user)
        flash[:notice] << "Order '#{order.name}' was successfully cancelled"
        order.destroy
      else
        flash[:error] << "Access violation. You can't cancel order '#{order.name}' with solution"
      end
    }
    redirect_to :action => 'edit_drafts'
  end
  
  def watch
    @orders = params[:id] ? [Order.find(params[:id])] : Order.find(params[:order_ids])
    @order = @orders[0]
    @orders.each{|order|
      unless current_user.watchlist.include?(order)
        current_user.watchlist << order
        @include = true
      else
        current_user.watchlist.delete(order)
        @include = false
      end
    }
    if params[:order_ids]
      redirect_to :action => 'edit_watchlist'
    else
      render 'orders/watchlist/watch'
    end
  end
  def edit_watchlist
    @watchlist = current_user.watchlist.search(current_user, Order::STATUS.constants,
      (params[:sort] if params[:sort][:table] == 'watchlist') )
    render 'orders/watchlist/edit'
  end 
  def edit_drafts
    @drafts = current_user.orders.search(current_user, [Order::STATUS::DRAFT],
      (params[:sort] if params[:sort][:table] == 'drafts') )
  end

  private
  def process_params
    params[:sort] ||= {}
    params[:sort].merge!(:page => params[:page])
  end
end
