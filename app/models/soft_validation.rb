class SoftValidation
  include Draper::Decoratable

  attr_reader :runtime

  delegate :issue_description, to: :database_script

  def self.run *args
    new(*args).tap(&:run)
  end

  def initialize record, database_script_klass
    @record = record
    @database_script_klass = database_script_klass
  end

  def run
    script_start = Time.current
    self.in_results = database_script_klass.record_in_results?(record)
    self.runtime = (Time.current - script_start).seconds
  end

  def failed?
    in_results
  end

  def database_script
    @database_script ||= database_script_klass.new
  end

  private

    attr_reader :record, :database_script_klass
    attr_accessor :in_results
    attr_writer :runtime
end
