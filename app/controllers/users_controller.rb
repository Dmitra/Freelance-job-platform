class UsersController < ApplicationController
  layout 'application'
  before_filter :not_logged_in_required, :only => [:new, :create] 
  before_filter :login_required, :only => [:show, :edit, :update]
  before_filter :check_administrator_role, :only => [:index, :destroy, :enable]

  def index
    @users = User.search(params[:search], params[:page])
  end
   
  def show
    if current_user.id == params[:id]
      @user = current_user
    else
      @user = User.find(params[:id])
      render :public
    end
  end
  
  def new
    @user = User.new
  end

  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    @user = User.new(params[:user])
    @user.login = params[:user][:login]
    if @user.save
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up! Please check your email to activate your account before logging in."
    else
      render :action => 'new'
    end
  end

  def edit
    @user = current_user
  end
   
  def update
    @user = User.find(current_user)
    process_file_uploads(@user)
    
    if @user.update_attributes(params[:user])
      flash[:notice] = "User updated"
      redirect_to :action => 'show_private', :id => current_user
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    redirect_to :action => 'index'
  end

  def disable
    set_enabled(false)
  end
  def enable
    User.update_all(["enabled = ?", true], :id => params[:user_ids])
    redirect_to :action => 'index'
  end

  def show_private
    if current_user.admin?
      @user = User.find_by_login(params[:login])
    else
      @user = current_user
    end
    render :action => :show
  end
  private
  def set_enabled(status)
    @user = User.find(params[:id])
    if @user.update_attribute(:enabled, status)
      flash[:notice] = "User disabled"
    else
      flash[:error] = "There was a problem disabling this user."
    end
    redirect_to :action => 'index'
  end
end
