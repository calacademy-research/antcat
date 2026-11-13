# frozen_string_literal: true

# The child taxa of a taxon.
#
# Routes: GET /taxa/:taxon_id/children (anyone). Purpose, rights and tests of each: docs/catalog/routes.tsv.
module Taxa
  class ChildrenController < ApplicationController
    def show
      @taxon = find_taxon

      @children = TaxonQuery.new(@taxon.immediate_children).with_common_includes.
        order(status: :desc, name_cache: :asc).
        paginate(per_page: 100, page: params[:page])
      @check_what_links_heres = params[:check_what_links_heres]
    end

    private

      def find_taxon
        Taxon.find(params.expect(:taxon_id))
      end
  end
end
