# frozen_string_literal: true

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
