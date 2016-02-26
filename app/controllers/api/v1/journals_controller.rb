module Api::V1
  class JournalsController < Api::ApiController
    def index
      super Journal
    end

    def show
      super Journal
    end
  end
end