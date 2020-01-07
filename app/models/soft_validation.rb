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
    in_results && !looks_like_a_false_positive?
  end

  def looks_like_a_false_positive?
    return false unless database_script_klass.respond_to?(:looks_like_a_false_positive?)
    @looks_like_a_false_positive ||= in_results && database_script_klass.looks_like_a_false_positive?(record)
  end

  def database_script
    @database_script ||= database_script_klass.new
  end

  private

    attr_reader :record, :database_script_klass
    attr_accessor :in_results
    attr_writer :runtime
end
