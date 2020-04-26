# frozen_string_literal: true

module Operations
  class ConvertToObsoleteCombination
    include Operation

    attr_private_initialize [:current_valid_taxon, :new_combination]

    def self.description current_valid_taxon:, new_combination:
      obsolete_combinations_description = current_valid_taxon.obsolete_combinations.map do |taxon|
        "  * #{CatalogFormatter.link_to_taxon(taxon)} (#{taxon.status})"
      end.join("\n").presence || "  * #{current_valid_taxon} has no obsolete combinations"

      <<~TEXT
        * Change #{current_valid_taxon} status from #{current_valid_taxon.status} to obsolete combination
        * Change #{current_valid_taxon} to set its `current_valid_taxon` to #{new_combination}
        * Update obsolete combinations of #{current_valid_taxon} to set their `current_valid_taxon` to #{new_combination}
        #{obsolete_combinations_description}
      TEXT
    end

    def execute
      update_status_and_current_valid_taxon
      update_current_valid_taxon_of_obsolete_combinations
    end

    private

      def update_status_and_current_valid_taxon
        unless current_valid_taxon.update(status: Status::OBSOLETE_COMBINATION, current_valid_taxon: new_combination)
          fail! current_valid_taxon.errors.full_messages.to_sentence
        end
      end

      def update_current_valid_taxon_of_obsolete_combinations
        current_valid_taxon.reload.obsolete_combinations.each do |obsolete_combination|
          unless obsolete_combination.update(current_valid_taxon: new_combination)
            fail! obsolete_combination.errors.full_messages.to_sentence
          end
        end
      end
  end
end
