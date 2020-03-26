# frozen_string_literal: true

# A `Context` is used for keeping track of multiple `Operations`s.

module Operation
  class Context
    def initialize
      @executed_operations = []
    end

    def failure?
      executed_operations.any? { |operation| operation.results.failure? }
    end

    def success?
      !failure?
    end

    def operation_was_executed instance
      executed_operations << instance
    end

    def first_executed_operation? instance
      executed_operations.first == instance
    end

    def errors
      executed_operations.map do |operation|
        operation.errors.errors
      end.compact.flatten
    end

    attr_reader :executed_operations
  end
end
