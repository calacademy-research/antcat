class ProtonymsController < ApplicationController
  before_action :set_protonym, only: [:show]

  def index
    @protonyms = Protonym.includes(:name, authorship: :reference).
      order_by_name.paginate(page: params[:page], per_page: 50)
  end

  def show
  end

  private

    def set_protonym
      @protonym = Protonym.find(params[:id])
    end
end
