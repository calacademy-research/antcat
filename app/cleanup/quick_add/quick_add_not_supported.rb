# frozen_string_literal: true

# Quick add: the adder for a case that is not supported; it cannot add and says why.
module QuickAdd
  class QuickAddNotSupported
    def initialize error_message
      @error_message = error_message
    end

    def can_add?
      false
    end

    def synopsis
      error_message
    end

    private

      attr_reader :error_message
  end
end
