module Operation
  Failure = Class.new(StandardError)

  def self.included base
    base.instance_eval do
      attr_accessor :context, :results, :errors

      delegate :success?, :failure?, to: :context
    end
  end

  def run context = Context.new
    self.context = context
    self.results = Results.new
    self.errors = Errors.new
    self.context.operation_was_executed(self)

    execute

    self
  rescue Failure
    raise unless context.first_executed_operation?(self)
    self
  end

  def execute
    raise NotImplementedError
  end

  def fail! error = nil
    errors.add(error) if error
    results.fail!
    raise Failure
  end
end
