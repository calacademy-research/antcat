module Protonyms
  class SoftValidationsController < ApplicationController
    before_action :set_protonym, only: :show

    def show
      @soft_validations = @protonym.soft_validations
    end

    private

      def set_protonym
        @protonym = Protonym.find(params[:protonym_id])
      end
  end
end
