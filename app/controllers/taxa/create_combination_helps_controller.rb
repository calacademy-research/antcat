module Taxa
  class CreateCombinationHelpsController < ApplicationController
    def new
      @taxon = find_taxon
      @target_rank = target_rank
    end

    def show
      @taxon = find_taxon
      @new_parent = find_new_parent

      unless @new_parent
        redirect_to({ action: :new }, alert: "Target must be specified.")
        return
      end

      @possibly_existing_combinations = possibly_existing_combinations
    end

    private

      def find_taxon
        Taxon.find(params[:taxa_id])
      end

      def find_new_parent
        Taxon.find_by(id: params[:new_parent_id])
      end

      def possibly_existing_combinations
        genus = @new_parent.is_a?(Genus) ? @new_parent : @new_parent.genus
        Taxa::FindEpithetInGenus[genus, @taxon.name.epithet]
      end

      def target_rank
        case @taxon
        when Species    then :genus
        when Subspecies then :species
        end
      end
  end
end
