module SortableHelper
    def sorted_column?(table, header) #if this column is already sorted
      if header[:column] == params[:sort][:column] && table == params[:sort][:table]
        params[:sort][:order]
      elsif header[:default] && params[:sort][:table] != table
        header[:order]
      end
    end
    def render_headings(columns, *args)
      table = args[0] || 'table'
      path_to_update = args[1] || false
      html = ''
      html << (content_tag :td) if path_to_update
        columns.each do |header|
          sorted_column = sorted_column?(table, header)
          if sorted_column
            sort_order = sorted_column == 'ASC' ? 'DESC' : 'ASC'    #reverse sorting
            sort_class = sorted_column == 'ASC' ? 'sortup' : 'sortdown'
          else
            sort_order = header[:order] ? header[:order] : 'ASC'
          end
          header_link = request.path_parameters.merge({:sort => {:column => header[:column], :order => sort_order, :table => table}}).merge(:search => request.params[:search])

          html << (content_tag :td, (link_to header[:display], header_link), :class => sort_class)
        end
        return html
    end
end
