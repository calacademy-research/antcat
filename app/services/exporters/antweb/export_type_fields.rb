module Exporters
  module Antweb
    class ExportTypeFields
      include Service

      def initialize protonym
        @protonym = protonym
      end

      def call
        formatted_type_fields.compact.join(' ').html_safe
      end

      private

        attr_reader :protonym

        delegate :primary_type_information_taxt, :secondary_type_information_taxt, :type_notes_taxt, to: :protonym

        def formatted_type_fields
          [primary_type_information, secondary_type_information, type_notes]
        end

        def primary_type_information
          return unless primary_type_information_taxt
          "Primary type information: #{detax(primary_type_information_taxt)}"
        end

        def secondary_type_information
          return unless secondary_type_information_taxt
          "Secondary type information: #{detax(secondary_type_information_taxt)}"
        end

        def type_notes
          return unless type_notes_taxt
          "Type notes: #{detax(type_notes_taxt)}"
        end

        def detax content
          AntwebDetax[content]
        end
    end
  end
end
