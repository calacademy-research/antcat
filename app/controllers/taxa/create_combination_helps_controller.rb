module Taxa
  class CreateCombinationHelpsController < ApplicationController
    before_action :set_taxon
    before_action :set_new_parent, only: :show

    def new
      @target_rank = target_rank
    end

    def show
      unless @new_parent
        redirect_to({ action: :new }, alert: "Target must be specified.")
        return
      end

      @possibly_existing_combinations = possibly_existing_combinations
    end

    private

      def set_taxon
        @taxon = Taxon.find(params[:taxa_id])
      end

      def set_new_parent
        @new_parent = Taxon.find_by(id: params[:new_parent_id])
      end

      def possibly_existing_combinations
        if @taxon.is_a? Subspecies
          @new_parent.parent.find_subspecies_in_genus(@taxon.name.epithet)
        else
          @new_parent.find_epithet_in_genus(@taxon.name.epithet)
        end
      end

      def target_rank
        case @taxon
        when Species    then :genus
        when Subspecies then :species
        end
      end
  end
end
