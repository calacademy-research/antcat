# frozen_string_literal: true

module Taxa
  class ChildrenController < ApplicationController
    def show
      @taxon = find_taxon

      @children = TaxonQuery.new(@taxon.children).with_common_includes.
        order(status: :desc, name_cache: :asc).
        paginate(per_page: 100, page: params[:page])
      @check_what_links_heres = params[:check_what_links_heres]
    end

    private

      def find_taxon
        Taxon.find(params[:taxa_id])
      end
  end
end
