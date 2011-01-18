class CommentsController < ApplicationController
  def create
    klass = ""
    params.each_key{|k| temp = k.to_s.match(/(.+)_id/)
      klass = temp unless temp.nil?} 
    commentable = eval(klass[1].capitalize).find(params[klass[0].to_sym])
    params[:comment][:user_id] = current_user.id
    @comment = commentable.comments.create(params[:comment])
  end
  def destroy
    @comment = Comment.find(params[:id]).destroy
  end
  
end
