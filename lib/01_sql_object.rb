require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    output = DBConnection.execute2(<<-SQL)
    SELECT
      *
    FROM
      #{self.table_name}
    SQL

    output.first.map! do |string|
      string.to_sym
    end
  end

  def self.finalize!
    columns.each do |col|
      define_method col do
        attributes[col]
      end

      define_method "#{col}=" do |val|
        attributes[col] = val
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
    SELECT
      *
    FROM
     (#{self.table_name})
    SQL

    parse_all(results)
  end

  def self.parse_all(results)
    results.map do |hash|
      self.new(hash)
    end
  end

  def self.find(id)
    results = DBConnection.execute(<<-SQL, id)
    SELECT
      *
    FROM
     #{self.table_name}
    WHERE
      id = ?
    SQL
    return nil if results.empty?
    self.new(results.first)
  end

  def initialize(params = {})
    params.each do |k, v|
      k = k.to_sym
      raise "unknown attribute '#{k}'" if !self.class.columns.include?(k)
      self.send "#{k}=", v
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    values = []
    self.class.columns.map do |key|
      if self.send(key).nil?
        next
      else
        values << self.send(key)
      end
    end

    values
  end

  def insert
    values = attribute_values
    col_names = "(#{attributes.keys.join(', ')})"
    question_marks = "(#{(["?"] * attribute_values.length).join(', ')})"
    DBConnection.execute(<<-SQL, *values)
    INSERT INTO
      #{self.class.table_name} #{col_names}
    VALUES
     #{question_marks}
    SQL

    self.send "id=", DBConnection.last_insert_row_id
  end

  def update
    col_names = attributes.keys.drop(1).map! do |attr_name|
      attr_name = "#{attr_name} = ?"
    end.join(', ')
    values = attribute_values.rotate!
    DBConnection.execute(<<-SQL, *values)
    UPDATE
      #{self.class.table_name}
    SET
      #{col_names}
    WHERE
      id = ?
    SQL
  end

  def save
    if self.id.nil?
      insert
    else
      update
    end
  end
end
