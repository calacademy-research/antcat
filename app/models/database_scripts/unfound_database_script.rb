# frozen_string_literal: true

module DatabaseScripts
  UnfoundDatabaseScript = Struct.new(:class_name) do
    def title
      "Error: Could not find database script with class name '#{class_name}'"
    end

    def filename_without_extension
      @_filename_without_extension ||= class_name.underscore
    end

    def tags
      []
    end

    alias_method :to_param, :filename_without_extension
  end
end
