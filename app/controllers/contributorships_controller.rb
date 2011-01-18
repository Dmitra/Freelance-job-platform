class ContributorshipsController < ApplicationController
  
  def index
    @user = current_user
    @contributorship = @user.contributorships.paginate(:per_page => property(:orders_per_page_count), :page => params[:page])
  end
  def create
    @contributorship = current_user.contributorships.build(:contributor_id => params[:user_id], :contribution_id => params[:order_id])
    if @contributorship.save
      flash[:notice] = "Added contributor"
    else
      flash[:error] = "Unable to add contributor"
    end
    redirect_to :action => 'index'
  end
  def destroy
    current_user.contributorships.find(params[:id]).destroy
#TODO When contributor can be deleted?
    flash[:notice] = "Removed contributor"
    redirect_to :action => 'index'
  end
end