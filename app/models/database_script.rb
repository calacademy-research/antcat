# frozen_string_literal: true

# Use `rails generate database_script <name_of_script>` to generate new scripts.

class DatabaseScript
  include Draper::Decoratable
  include DatabaseScripts::Rendering
  include DatabaseScripts::ViewHelpers

  SCRIPTS_DIR = "app/database_scripts/database_scripts"
  TAGS = [
    SLOW_TAG = "slow",
    VERY_SLOW_TAG = "very-slow",
    SLOW_RENDER_TAG = "slow-render",
    NEW_TAG = "new!",
    UPDATED = "updated!",
    CSV_TAG = "csv",
    REGRESSION_TEST_TAG = "regression-test",
    LIST_TAG = "list",
    VALIDATED_TAG = "validated",
    HAS_QUICK_FIX_TAG = "has-quick-fix",
    HIGH_PRIORITY_TAG = "high-priority"
  ]

  ScriptNotFound = Class.new StandardError

  attr_accessor :results_runtime

  delegate :category, :tags, :issue_description, :description, to: :end_data_attributes

  def self.inherited subclass
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
    DatabaseScripts::UnfoundDatabaseScript.new(class_name)
  end

  def self.all
    @all ||= Dir.glob("#{SCRIPTS_DIR}/*").sort.map do |path|
               basename = File.basename path, ".rb"
               new_from_filename_without_extension basename
             end
  end

  # TODO: Indicate record type in scripts.
  def self.record_in_results? record
    new.results.where(id: record.id).exists?
  end

  def soft_validated?
    self.class.in?(SoftValidations::ALL_DATABASE_SCRIPTS_TO_CHECK)
  end

  def fix_random?
    self.class.in?(Catalog::FixRandomController::DATABASE_SCRIPTS_TO_CHECK)
  end

  def slow?
    tags.include?(SLOW_TAG) || tags.include?(VERY_SLOW_TAG)
  end

  def title
    end_data_attributes.title || filename_without_extension.humanize.humanize(keep_id_suffix: false)
  end

  def related_scripts
    end_data_attributes.related_scripts.reject { |database_script| database_script.is_a?(self.class) }
  end

  def statistics
    @statistics ||= default_statistics
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
      return @results if defined? @results
      if respond_to?(:results)
        start = Time.current
        @results = results
        @results = @results.load if @results.is_a?(ActiveRecord::Relation)
        self.results_runtime = Time.current - start
      end
      @results
    end

  private

    def end_data_attributes
      @end_data_attributes ||= DatabaseScripts::EndDataAttributes.new(script_path)
    end

    def script_path
      "#{SCRIPTS_DIR}/#{filename_without_extension}.rb"
    end

    def default_statistics
      return unless respond_to? :results
      count = cached_results.count
      count = count.count if count.is_a?(Hash) # HACK: For grouped queries.
      "Results: #{count}"
    end
end
