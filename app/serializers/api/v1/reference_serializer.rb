# frozen_string_literal: true

module Api
  module V1
    class ReferenceSerializer
      attr_private_initialize :reference

      def as_json _options = {}
        reference.as_json(root: true)
      end
    end
  end
end
