class ActivityObserver < ActiveRecord::Observer
  observe :order, :solution

  def after_update(record)
    if (Time.now - record.updated_at) < 2 
      if record.class == Order
        comment(record, "Order was edited")
      else
        comment(record.order, "Solution was evaluated")                 if record.evaluated?
        comment(record.order, "Order was done with accepted solution")  if record.accepted?
        comment(record.order, "One solution was refused")               if record.refused?
        comment(record.order, "Solution was deleted", record.user)      if record.deleted?
      end 
    end
  end
  def comment(order, message, comment_author=nil)
    comment_author ||= order.user
    order.comments.create(:user_id => comment_author.id, :title => "Activity log", :comment => message)
  end
end
