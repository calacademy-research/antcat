# frozen_string_literal: true

# TODO: Copy-pasted from `Taxa::Operations::ReorderHistoryItems`.

module Taxa
  module Operations
    class ReorderReferenceSections
      include Service

      attr_private_initialize :taxon, :reordered_ids

      def call
        reorder_reference_sections reordered_ids
      end

      private

        delegate :reference_sections, :errors, to: :taxon, private: true

        def reorder_reference_sections reordered_ids
          return false unless reordered_ids_valid? reordered_ids

          taxon.transaction do
            reordered_ids.each_with_index do |id, index|
              reference_section = ReferenceSection.find(id)
              reference_section.update!(position: (index + 1))
            end
          end

          true
        rescue ActiveRecord::RecordInvalid
          errors.add :reference_sections, "Reference sections are not valid, please fix them first"
          false
        end

        def reordered_ids_valid? reordered_ids_strings
          current_ids = reference_sections.pluck(:id)
          reordered_ids = reordered_ids_strings.map(&:to_i)

          if current_ids == reordered_ids
            errors.add :reference_sections, "Reference sections are already ordered like this"
          end

          unless current_ids.sort == reordered_ids.sort
            errors.add :reference_sections, <<-ERROR.squish
              Reordered IDs '#{reordered_ids}' doesn't match current IDs #{current_ids}.
            ERROR
          end

          errors.empty?
        end
    end
  end
end
