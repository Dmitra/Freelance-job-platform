module Sortable

  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
  end

  module ClassMethods
    @@headings = {}

    def headings(table)
      @@headings[table]
    end

    def table_columns(table)
      headings(table).map{|head| head[:column]}
    end
    def default_sort(table)
      headings(table).each{|h| return h if h[:default]}
    end
    def headings_set(table, array)
      @@headings[table] = array.inject([]){ |hash, h|
        hash << {:display => h[0], :column => h[1]}
        hash.last[:order] = h[2] if h[2]
        if h[3]
          hash.last[:default] = true    unless @has_default
          @has_default = true
        end
        hash
      }
      @@headings[table][0][:default] = true and @@headings[table][0][:order] = 'ASC' unless @has_default
    end
  end

  module InstanceMethods
  end
end
