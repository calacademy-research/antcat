# frozen_string_literal: true

module Exporters
  module Antweb
    module History
      class ProtonymSynopsis
        class TypeFields
          include Service

          attr_private_initialize :protonym

          def call
            formatted_type_fields.compact.join(' ').html_safe
          end

          private

            delegate :primary_type_information_taxt, :secondary_type_information_taxt,
              :type_notes_taxt, to: :protonym, private: true

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
              AntwebFormatter.detax(content)
            end
        end
      end
    end
  end
end
