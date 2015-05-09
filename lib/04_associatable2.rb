require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    define_method name do

      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      results = DBConnection.execute(<<-SQL, value)
      SELECT
        #{houses}.*
      FROM
        #{humans}
      JOIN
        #{houses} ON #{humans}.#{house_id} = #{houses}.#{id}
      WHERE
        #{humans}.#{id} = ?
      SQL
      source_options.class_name.constantize.new(results.first)
    end
  end
end
