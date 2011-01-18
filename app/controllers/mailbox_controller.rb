class MailboxController < ApplicationController
  def index
#    redirect_to new_session_path and return unless logged_in?
    @folder = current_user.inbox
#    show
    @messages = @folder.messages.paginate_not_deleted :all, :per_page => 10, :page => params[:page],
          :include => :message, :order => "messages.created_at DESC"

    render :action => "show"
  end

  def show
    @folder ||= current_user.folders.find(params[:id])
    @messages = @folder.messages.paginate_not_deleted :all, :per_page => 10, :page => params[:page],
          :include => :message, :order => "messages.created_at DESC"
  end
  
  def trash
    @folder = Struct.new(:name, :user_id).new("Trash", current_user.id)
    @messages = current_user.received_messages.paginate_deleted :all, :per_page => 10, :page => params[:page],
          :include => :message, :order => "messages.created_at DESC"
    render :action => "show"
  end
end
