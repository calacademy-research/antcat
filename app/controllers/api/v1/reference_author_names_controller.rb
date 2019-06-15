module Api
  module V1
    class ReferenceAuthorNamesController < Api::ApiController
      def index
        super ReferenceAuthorName
      end

      def show
        super ReferenceAuthorName
      end
    end
  end
end
