# frozen_string_literal: true

# The errors an operation collected while it ran.
module Operation
  class Errors
    def initialize
      @errors = []
    end

    def add error
      errors << error
    end

    attr_reader :errors
  end
end
