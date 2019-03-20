class ProtonymsController < ApplicationController
  before_action :ensure_user_is_at_least_helper, only: :destroy
  before_action :set_protonym, only: [:show, :destroy]

  def index
    @protonyms = Protonym.includes(:name, authorship: :reference).
      order_by_name.paginate(page: params[:page], per_page: 50)
  end

  def show
  end

  def destroy
    @protonym.destroy
    @protonym.create_activity :destroy
    redirect_to protonyms_path, notice: "Successfully deleted protonym."
  end

  private

    def set_protonym
      @protonym = Protonym.find(params[:id])
    end
end
