module OrdersHelper
  def render_orders(orders, table, path_to_update)
    html = ''
    html << (form_tag path_to_update) if path_to_update
    html << (orders.map do |order|
      content_tag :tr,
        ((content_tag :td, (check_box_tag "order_ids[]", order.id)) if path_to_update
         render :partial => 'order', :locals => {:order => order, :columns => Order.table_columns(table)}),
      :class => [cycle('odd', 'even'), (" bold" if order.font), (" color" if order.color)]
    
    end.join)
    html << (submit_tag "Delete", :confirm => "Do U really want to delete selected items?") if path_to_update
    return html
  end
end
