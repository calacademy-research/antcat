# frozen_string_literal: true

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
