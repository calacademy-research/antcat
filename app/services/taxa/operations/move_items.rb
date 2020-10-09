# frozen_string_literal: true

module Taxa
  module Operations
    class MoveItems
      class ReferenceSectionsNotSupportedForRank < StandardError; end

      include Service

      attr_private_initialize :to_taxon, [reference_sections: []]

      def call
        raise ReferenceSectionsNotSupportedForRank if cannot_move_reference_sections?

        move_reference_sections!
      end

      private

        def cannot_move_reference_sections?
          return if reference_sections.blank?
          !to_taxon.type.in?(Rank::AntCatSpecific::CAN_HAVE_REFERENCE_SECTIONS_TYPES)
        end

        def move_reference_sections!
          reference_sections.each do |reference_section|
            reference_section.reload # Reload to make sure positions are updated correctly.

            reference_section.taxon = to_taxon
            reference_section.save!
          end
        end
    end
  end
end
