require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_line = params.keys.map do |k|
      "#{k} = ?"
    end.join(' AND ')
    values = params.values
    result = DBConnection.execute(<<-SQL, *values)
    SELECT
      *
    FROM
      #{self.table_name}
    WHERE
      #{where_line}
    SQL

    self.parse_all(result)
  end
end

class SQLObject
  extend Searchable
end
