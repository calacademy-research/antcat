# frozen_string_literal: true

module My
  class DefaultReferenceController < ApplicationController
    before_action :authenticate_user!

    def update
      reference = find_reference
      References::DefaultReference.set(session, reference)

      redirect_back fallback_location: references_path,
        notice: "#{reference.key_with_suffixed_year} was successfully set as the default reference."
    end

    private

      def find_reference
        Reference.find(params[:id])
      end
  end
end
