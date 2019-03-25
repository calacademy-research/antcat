class ProtonymsController < ApplicationController
  before_action :ensure_user_is_at_least_helper, except: [:index, :show]
  before_action :set_protonym, only: [:show, :edit, :update, :destroy]

  def index
    @protonyms = Protonym.includes(:name, authorship: :reference).
      order_by_name.paginate(page: params[:page], per_page: 50)
  end

  def show
  end

  def edit
  end

  def update
    if @protonym.update protonym_params
      redirect_to @protonym, notice: 'Protonym was successfully updated.'
    else
      render :edit
    end
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

    def protonym_params
      params.require(:protonym).permit(
        :fossil,
        :sic,
        :locality,
        {
          authorship_attributes: [
            :pages,
            :forms,
            :notes_taxt,
            :reference_id
          ]
        }
      )
    end
end
