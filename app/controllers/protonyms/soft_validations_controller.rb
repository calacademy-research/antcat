# frozen_string_literal: true

# Database checks of one protonym.
#
# Routes: GET /protonyms/:protonym_id/soft_validations (anyone). Purpose, rights and tests of each:
# docs/catalog/routes.tsv.
module Protonyms
  class SoftValidationsController < ApplicationController
    def show
      @protonym = find_protonym
      @soft_validations = @protonym.soft_validations
    end

    private

      def find_protonym
        Protonym.find(params.expect(:protonym_id))
      end
  end
end
