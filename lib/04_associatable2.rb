require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    define_method name do
      through_options.model_class.assoc_options[source_name]
      # source_name.pluralize.where(through_name.id = options.)
      # source_name. HasManyThrough(through_name.pluralize)
    end
  end
end
