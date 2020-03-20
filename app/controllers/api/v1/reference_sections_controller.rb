module Api
  module V1
    class ReferenceSectionsController < Api::ApiController
      def index
        render json: with_limit(ReferenceSection.all)
      end

      def show
        super ReferenceSection
      end
    end
  end
end
