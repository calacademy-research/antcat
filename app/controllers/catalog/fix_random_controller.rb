module Catalog
  class FixRandomController < ApplicationController
    def show
      if taxon
        redirect_to catalog_path(taxon)
      else
        redirect_to database_scripts_path, notice: <<~MSG
          Whaaaat?? All randomizable ants with issues have been fixed!
          But you may still be able to find more things to fix in this list :)
        MSG
      end
    end

    private

      # HACK: Naive but lazy (not eager) implementation.
      def taxon
        @taxon ||= Taxa::CallbacksAndValidations::DATABASE_SCRIPTS_TO_CHECK.
                     map(&:new).shuffle.lazy.
                     map { |script| script.results.sample }.
                     detect { |taxon| taxon }
      end
  end
end