module Api::V1
  class ProtonymsController < Api::ApiController
    # rest endpoint - get protonym/[id]
    def show
      begin
        protonym = Protonym.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render nothing: true, status: :not_found
        return
      end

      render json: protonym, status: :ok
    end
  end
end