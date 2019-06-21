# Show children on another page for performance reasons.
# Example of a very slow page: http://localhost:3000/taxa/429244/edit

module Taxa
  class ChildrenController < ApplicationController
    before_action :set_taxon

    def show
      @children = @taxon.children.includes(:name).order(status: :desc, name_cache: :asc).paginate(per_page: 1000, page: params[:page])
    end

    private

      def set_taxon
        @taxon = Taxon.find(params[:taxa_id])
      end
  end
end
