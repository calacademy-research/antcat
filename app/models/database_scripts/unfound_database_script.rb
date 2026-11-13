# frozen_string_literal: true

# Stands in for a database script that is named somewhere (a related-scripts list) but does not exist; shows an
# error title.
module DatabaseScripts
  UnfoundDatabaseScript = Struct.new(:class_name) do
    def title
      "Error: Could not find database script with class name '#{class_name}'"
    end

    def basename
      @_basename ||= class_name.underscore
    end

    def section
    end

    def tags
      []
    end

    alias_method :to_param, :basename
  end
end
