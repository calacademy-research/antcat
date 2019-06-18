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
    @protonym.name = Names::BuildNameFromString[params[:protonym_name_string]]

    if @protonym.save
      @protonym.create_activity :create, edit_summary: params[:edit_summary]
      redirect_to @protonym, notice: 'Protonym was successfully created.'
    else
      render :new
    end
  rescue Names::BuildNameFromString::UnparsableName => e
    @protonym.errors.add :base, "Could not parse name #{e.message}"
    @protonym.build_name(name: params[:protonym_name_string]) # Maintain entered name.
    render :new
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
      params.require(:protonym).permit(
        :fossil,
        :sic,
        :biogeographic_region,
        :locality,
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
