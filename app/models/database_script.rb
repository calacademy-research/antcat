# Use `rails generate database_script <name_of_script>` to generate new scripts.

class DatabaseScript
  include Draper::Decoratable
  include DatabaseScripts::EndData
  include DatabaseScripts::Rendering

  SCRIPTS_DIR = "app/database_scripts/database_scripts"
  TAGS = [
    SLOW_TAG = "slow",
    VERY_SLOW_TAG = "very-slow",
    NEW_TAG = "new!",
    UPDATED = "updated!",
    CSV_TAG = "csv",
    REGRESSION_TEST_TAG = "regression-test",
    LIST_TAG = "list",
    VALIDATED_TAG = "validated",
    HIGH_PRIORITY_TAG = "high-priority"
  ]

  ScriptNotFound = Class.new StandardError

  UnfoundDatabaseScript = Struct.new(:class_name) do
    def title
      "Error: Could not find database script with class name '#{class_name}'"
    end

    def filename_without_extension
      @filename_without_extension ||= class_name.underscore
    end

    def tags
      []
    end

    alias_method :to_param, :filename_without_extension
  end

  def self.inherited(subclass)
    subclass.include Rails.application.routes.url_helpers
    subclass.include ActionView::Helpers::UrlHelper
  end

  def self.new_from_filename_without_extension basename
    script_class = "DatabaseScripts::#{basename.camelize}".safe_constantize
    raise ScriptNotFound unless script_class

    script_class.new
  end

  def self.safe_new_from_filename_without_extension class_name
    new_from_filename_without_extension class_name
  rescue DatabaseScript::ScriptNotFound
    UnfoundDatabaseScript.new(class_name)
  end

  def self.all
    @all ||= Dir.glob("#{SCRIPTS_DIR}/*").sort.map do |path|
               basename = File.basename path, ".rb"
               new_from_filename_without_extension basename
             end
  end

  def self.record_in_results? taxon
    new.results.where(id: taxon.id).exists?
  end

  def soft_validated?
    self.class.in?(SoftValidations::ALL_DATABASE_SCRIPTS_TO_CHECK)
  end

  def fix_random?
    self.class.in?(Catalog::FixRandomController::DATABASE_SCRIPTS_TO_CHECK)
  end

  def title
    end_data[:title]&.html_safe || filename_without_extension.humanize
  end

  def category
    end_data[:category] || ""
  end

  def tags
    end_data[:tags] || []
  end

  def issue_description
    end_data[:issue_description]
  end

  def description
    end_data[:description] || ""
  end

  def related_scripts
    (end_data[:related_scripts] || []).map do |class_name|
      self.class.safe_new_from_filename_without_extension class_name
    end.reject { |database_script| database_script.is_a?(self.class) }
  end

  def statistics
    @statistics ||= default_statistics
  end

  def slow?
    tags.include?(SLOW_TAG) || tags.include?(VERY_SLOW_TAG)
  end

  def filename_without_extension
    @filename_without_extension ||= self.class.name.demodulize.underscore
  end

  # For `link_to "database_script", database_script_path(@database_script)`.
  def to_param
    filename_without_extension
  end

  protected

    def cached_results
      return @_results if defined? @_results
      @_results = results if respond_to?(:results)
    end

  private

    def script_path
      "#{SCRIPTS_DIR}/#{filename_without_extension}.rb"
    end

    def default_statistics
      return if hide_statistics?
      return unless respond_to? :results
      count = cached_results.count
      count = count.count if count.is_a?(Hash) # HACK: For grouped queries.
      "Results: #{count}"
    end

    def hide_statistics?
      end_data[:hide_statistics] || false
    end
end
