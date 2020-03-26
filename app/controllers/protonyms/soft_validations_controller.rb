# frozen_string_literal: true

module Protonyms
  class SoftValidationsController < ApplicationController
    def show
      @protonym = find_protonym
      @soft_validations = @protonym.soft_validations
    end

    private

      def find_protonym
        Protonym.find(params[:protonym_id])
      end
  end
end
