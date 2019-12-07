module Operations
  class ConvertToObsoleteCombination
    include Operation

    def initialize current_valid_taxon:, new_combination:
      @current_valid_taxon = current_valid_taxon
      @new_combination = new_combination
    end

    def self.description current_valid_taxon:, new_combination:
      <<~TEXT
        * Change #{current_valid_taxon} status from #{current_valid_taxon.status} to obsolete combination
        * Change #{current_valid_taxon} to set its `current_valid_taxon` to #{new_combination}
      TEXT
    end

    def execute
      unless current_valid_taxon.update(status: Status::OBSOLETE_COMBINATION, current_valid_taxon: new_combination)
        fail! current_valid_taxon.errors.full_messages.to_sentence
      end
    end

    private

      attr_reader :current_valid_taxon, :new_combination
  end
end
