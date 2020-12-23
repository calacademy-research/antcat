# frozen_string_literal: true

module History
  class Definition
    def initialize type_attributes
      @type_attributes = type_attributes
    end

    def groupable?
      type_attributes[:group_key].present?
    end

    private

      attr_reader :type_attributes
  end
end
