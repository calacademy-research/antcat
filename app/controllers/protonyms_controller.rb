class ProtonymsController < ApplicationController
  before_action :ensure_user_is_at_least_helper, except: [:index, :show]
  before_action :set_protonym, only: [:show, :edit, :update, :destroy]

  def index
    @protonyms = Protonym.includes(:name, authorship: :reference).
      order_by_name.paginate(page: params[:page], per_page: 50)
  end

  def show
  end

  def new
    @protonym = Protonym.new
    @protonym.build_name
    @protonym.build_authorship
  end

  def create
    @protonym = Protonym.new(protonym_params)

    if @protonym.save
      @protonym.create_activity :create, edit_summary: params[:edit_summary]
      redirect_to @protonym, notice: 'Protonym was successfully created.'
    else
      @protonym.build_name unless @protonym.name
      render :new
    end
  end

  def edit
  end

  def update
    if @protonym.update(protonym_params)
      @protonym.create_activity :update, edit_summary: params[:edit_summary]
      redirect_to @protonym, notice: 'Protonym was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    if @protonym.destroy
      @protonym.create_activity :destroy, edit_summary: params[:edit_summary]
      redirect_to protonyms_path, notice: "Successfully deleted protonym."
    else
      redirect_to @protonym, alert: @protonym.errors.full_messages.to_sentence
    end
  end

  def autocomplete
    search_query = params[:qq] || ''

    respond_to do |format|
      format.json do
        render json: Autocomplete::AutocompleteProtonyms[search_query]
      end
    end
  end

  private

    def set_protonym
      @protonym = Protonym.find(params[:id])
    end

    def protonym_params
      # TODO: Same hack as in `TaxonForm`.
      if params[:protonym][:name_id].present?
        params[:protonym].delete :name_attributes
      else
        if params[:protonym][:name_attributes].present?
          params[:protonym][:name_id] = params[:protonym][:name_attributes][:id]
        end
      end

      params.require(:protonym).permit(
        :fossil,
        :sic,
        :locality,
        :name_id,
        :primary_type_information_taxt,
        :secondary_type_information_taxt,
        :type_notes_taxt,
        {
          authorship_attributes: [
            :id,
            :pages,
            :forms,
            :notes_taxt,
            :reference_id
          ]
        }
      )
    end
end
