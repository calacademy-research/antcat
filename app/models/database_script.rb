# frozen_string_literal: true

# Use `rails generate database_script <name_of_script>` to generate new scripts.

class DatabaseScript
  include Draper::Decoratable

  SCRIPTS_DIR = "app/database_scripts/database_scripts"

  class ScriptNotFound < StandardError
  end

  attr_accessor :results_runtime

  delegate :title, :section, :tags, :issue_description, :description, :related_scripts, to: :end_data_attributes

  class << self
    def new_from_basename basename
      script_class = "DatabaseScripts::#{basename.camelize}".safe_constantize
      # Only database scripts: other classes in the namespace (`Render`, `EmptyStatus`, ...) are not found.
      raise ScriptNotFound unless script_class.is_a?(Class) && script_class < DatabaseScript
      script_class.new
    end

    def safe_new_from_basename basename
      new_from_basename(basename)
    rescue DatabaseScript::ScriptNotFound
      DatabaseScripts::UnfoundDatabaseScript.new(basename)
    end

    # New instances on every call: an instance keeps its results and statistics, which must not outlive a request.
    def all
      basenames.map { new_from_basename(it) }
    end

    def basenames
      @_basenames ||= Dir["#{SCRIPTS_DIR}/*"].map { |path| File.basename(path, ".rb") }.freeze
    end

    def with_tag tag_or_tags
      tags = Array.wrap(tag_or_tags)
      all.select { it.tags.intersect?(tags) }
    end

    # NOTE: `DatabaseScriptDecorator#empty?` is true for a script that is *not* empty (see its comment).
    def non_empty_regression_tests
      all.map(&:decorate).select(&:regression_test?).select(&:empty?).map(&:undecorate)
    end

    def record_in_results? record
      new.results.where(id: record.id).exists?
    end
  end

  def statistics
    @_statistics ||= default_statistics
  end

  # Filename without ".rb" extension.
  def basename
    @_basename ||= self.class.name.demodulize.underscore
  end

  def to_param
    basename
  end

  def execute
    raise NoMethodError, "implement method in subclass"
  end

  # TODO: See how pagination works out for us and improve code.
  def render_with_options_or_default options
    if paginate?
      render(results_to_render: paginated_results(page: options[:page].presence || 1))
    else
      render
    end
  end

  def paginate?
    respond_to?(:paginated_results)
  end

  protected

    # TODO: Probably remove.
    def cached_results
      return @_results if defined?(@_results)

      if respond_to?(:results)
        start = Time.current
        @_results = results
        @_results = @_results.load if @_results.is_a?(ActiveRecord::Relation)
        self.results_runtime = Time.current - start
      end

      @_results
    end

  private

    def end_data_attributes
      @_end_data_attributes ||= DatabaseScripts::EndDataAttributes.new(basename)
    end

    # TODO: Probably remove and/or inline special cases in `DatabaseScript` subclasses.
    def default_statistics
      return unless respond_to?(:results)

      count = cached_results.count
      count = count.count if count.is_a?(Hash) # HACK: For grouped queries.
      "Results: #{count}"
    end
end
