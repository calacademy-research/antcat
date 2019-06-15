module Api
  module V1
    class ReferenceSectionsController < Api::ApiController
      def index
        super ReferenceSection
      end

      def show
        super ReferenceSection
      end
    end
  end
end
