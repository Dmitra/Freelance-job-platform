class MessagesController < ApplicationController
  def show
    @message = current_user.received_messages.find(params[:id])
  end
  
  def destroy
    @message = current_user.received_messages.find(params[:id])
    @message.update_attribute("deleted", true)
    redirect_to inbox_path
  end
  
  def undelete
    @message = current_user.received_messages.find(params[:id])
    @message.update_attribute("deleted", false)
    redirect_to inbox_path
  end
  
  def reply
    @original = current_user.received_messages.find(params[:id])
    
    subject = @original.subject.sub(/^(Re: )?/, "Re: ")
    body = @original.body.gsub(/^/, "> ")
    @message = current_user.sent_messages.build(:to => [@original.author.id], :subject => subject, :body => body)
    render :template => "sent/new"
  end
  
  def forward
    @original = current_user.received_messages.find(params[:id])
    
    subject = @original.subject.sub(/^(Fwd: )?/, "Fwd: ")
    body = @original.body.gsub(/^/, "> ")
    @message = current_user.sent_messages.build(:subject => subject, :body => body)
    render :template => "sent/new"
  end
  
  def reply_all
    @original = current_user.received_messages.find(params[:id])
    
    subject = @original.subject.sub(/^(Re: )?/, "Re: ")
    body = @original.body.gsub(/^/, "> ")
    recipients = @original.recipients.map(&:id) - [current_user.id] + [@original.author.id] 
    @message = current_user.sent_messages.build(:to => recipients, :subject => subject, :body => body)
    render :template => "sent/new"
  end
end
