# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def safe_html(text)
    white_list simple_format(text)
  end   
  def title(page_title)
    content_for(:title) { page_title }
  end
  def time_to_now(from_time)
    distance = (((Time.now - from_time).abs)/60/60).round
    case distance
      when 0..1 then "1 hour"
      when 1..24 then "#{distance} hours"
      else "#{(distance/24).round + 1} days"
    end
  end
  def singularize(string)
    string.split(/\./).map{|m| m.singularize}.join('.')
  end
end
