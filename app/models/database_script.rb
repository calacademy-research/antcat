# Use `rails generate database_script <name_of_script>` to generate new scripts.

class DatabaseScript
  include DatabaseScripts::Rendering

  SCRIPTS_DIR = "app/database_scripts/database_scripts"
  ScriptNotFound = Class.new StandardError

  attr_reader :filename_without_extension

  def self.new_from_filename_without_extension basename
    script_class = "DatabaseScripts::#{basename.camelize}".safe_constantize
    raise ScriptNotFound unless script_class

    script_class.new
  end

  def self.all
    Dir.glob("#{SCRIPTS_DIR}/*").sort.map do |path|
      basename = File.basename path, ".rb"
      new_from_filename_without_extension basename
    end
  end

  def initialize
    @filename_without_extension = self.class.name.demodulize.underscore
  end

  def description
    end_data[:description] || ""
  end

  def tags
    end_data[:tags] || []
  end

  def topic_areas
    end_data[:topic_areas] || []
  end

  def title
    filename_without_extension.humanize
  end

  # Filename is generated from the script's class name, so presumably safe.
  def source_code
    File.read script_path
  end

  # For `link_to "script", database_script_path(@script)`.
  def to_param
    filename_without_extension
  end

  def cache_key
    "db_scripts/#{filename_without_extension}"
  end

  protected
    def sql sql
      ActiveRecord::Base.connection.exec_query sql
    end

    def cached_results
      return @results if defined? @results
      @results = results
    end

  private
    # The script's description and tags are stored in `DATA`.
    # TODO replace with methods.
    def end_data
      @_end_data ||= HashWithIndifferentAccess.new YAML::load(read_end_data)
    end

    # For reading the script's `DATA` (everything under `__END__` in the source);
    # just calling `DATA` doesn't always work in subclasses, mixins, etc.
    def read_end_data
      data = StringIO.new
      File.open(script_path) do |f|
        begin
          line = f.gets
        end until line.nil? || line.match(/^__END__$/)
        while line = f.gets
          data << line
        end
      end
      data.rewind
      data
    end

    def script_path
      "#{SCRIPTS_DIR}/#{filename_without_extension}.rb"
    end
end
