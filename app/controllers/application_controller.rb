# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  include AuthenticatedSystem
  require 'country_select'
  filter_parameter_logging "password"
  protect_from_forgery
  
  def check_order_author
    if logged_in?
      unless current_user == Order.find(params[:order_id]).user
        permission_denied
      end
    else
      store_referer
      access_denied
    end
  end
  
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def record_not_found
    flash[:error] = "Record not found"
    redirect_to :action => 'index'
  end
    protected
  def process_file_uploads(object)
      @assets = object.assets
      unless params[:attachment].nil?
        params[:attachment].each_value{|file| if File.file?(file)
              @assets.create(:data => file)
            end
        }
      end
  end
end
