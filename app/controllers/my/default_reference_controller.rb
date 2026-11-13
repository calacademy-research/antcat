# frozen_string_literal: true

# The editor's default reference.
#
# Routes: PATCH /my/default_reference (signed in); PUT /my/default_reference (signed in). Purpose, rights and tests
# of each: docs/catalog/routes.tsv.
module My
  class DefaultReferenceController < ApplicationController
    before_action :authenticate_user!

    def update
      reference = find_reference
      References::DefaultReference.set(session, reference)

      redirect_back_or_to(references_path, notice: "#{reference.key_with_suffixed_year} was successfully set as the default reference.")
    end

    private

      def find_reference
        Reference.find(params.expect(:id))
      end
  end
end
