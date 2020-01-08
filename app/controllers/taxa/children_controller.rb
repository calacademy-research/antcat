module Taxa
  class ChildrenController < ApplicationController
    before_action :set_taxon

    def show
      @children = @taxon.children.includes(:name).order(status: :desc, name_cache: :asc).paginate(per_page: 100, page: params[:page])
      @check_what_links_heres = params[:check_what_links_heres]
    end

    private

      def set_taxon
        @taxon = Taxon.find(params[:taxa_id])
      end
  end
end
