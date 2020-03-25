# This controller handles editing by logged in editors.
# `CatalogController` is responsible for showing taxon pages to users.

class TaxaController < ApplicationController
  before_action :ensure_user_is_editor
  before_action :set_taxon, only: [:edit, :update, :destroy]

  def new
    @taxon = build_taxon_with_parent
    @taxon.protonym.authorship.reference ||= DefaultReference.get session
    @default_name_string = Taxa::PrefilledTaxonFormName[@taxon]
  end

  def create
    @taxon = build_taxon_with_parent

    taxon_form = TaxonForm.new(
      @taxon,
      taxon_params,
      taxon_name_string: params[:taxon_name_string],
      protonym_name_string: params[:protonym_name_string].presence
    )

    if taxon_form.save
      @taxon.create_activity :create, current_user, edit_summary: params[:edit_summary]
      redirect_to catalog_path(@taxon), notice: "Taxon was successfully added." + add_another_species_link
    else
      render :new
    end
  rescue Names::BuildNameFromString::UnparsableName => e # TODO: Get rid of this rescue.
    @taxon.errors.add :base, "Could not parse name #{e.message}"
    # Maintain entered names.
    @taxon.build_name(name: params[:taxon_name_string]) unless @taxon.name.name
    @taxon.protonym.build_name(name: params[:protonym_name_string]) unless @taxon.protonym.name.name
    render :new
  end

  def edit
  end

  def update
    if @taxon.update(taxon_params)
      @taxon.create_activity :update, current_user, edit_summary: params[:edit_summary]
      redirect_to catalog_path(@taxon), notice: "Taxon was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    if @taxon.what_links_here.any?
      redirect_to taxon_what_links_here_path(@taxon), alert: <<~MSG
        Other taxa refer to this taxon, so it can't be deleted.
      MSG
      return
    end

    if @taxon.destroy
      @taxon.create_activity :destroy, current_user
      redirect_to catalog_path(@taxon.parent), notice: "Taxon was successfully deleted."
    else
      redirect_to catalog_path(@taxon.parent), alert: @taxon.errors.full_messages.to_sentence
    end
  end

  private

    def set_taxon
      @taxon = Taxon.find(params[:id])
    end

    def taxon_params
      params.require(:taxon).permit(
        :collective_group_name,
        :current_valid_taxon_id,
        :fossil,
        :headline_notes_taxt,
        :homonym_replaced_by_id,
        :hong,
        :ichnotaxon,
        :incertae_sedis_in,
        :nomen_nudum,
        :origin,
        :original_combination,
        :protonym_id,
        :status,
        :type_taxon_id,
        :type_taxt,
        :unresolved_homonym,
        name_attributes: [:gender],
        protonym_attributes: [
          :id, :biogeographic_region, :fossil, :locality, :primary_type_information_taxt,
          :secondary_type_information_taxt, :sic, :type_notes_taxt,
          { authorship_attributes: [:id, :forms, :notes_taxt, :pages, :reference_id] }
        ]
      )
    end

    def build_taxon_with_parent
      parent = Taxon.find(params[:parent_id])
      Taxa::BuildTaxon[params[:rank_to_create], parent]
    end

    def add_another_species_link
      return "" unless @taxon.is_a? Species

      link = view_context.link_to "Add another #{@taxon.genus.name_html_cache} species?".html_safe,
        new_taxa_path(rank_to_create: "Species", parent_id: @taxon.genus.id)

      " <strong>#{link}</strong>".html_safe
    end
end
