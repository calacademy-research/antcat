# This controller handles editing by logged in editors.
# `CatalogController` is responsible for showing taxon pages to users.

class TaxaController < ApplicationController
  before_action :ensure_user_is_editor
  before_action :set_taxon, only: [:edit, :update, :destroy]

  def new
    @taxon = build_taxon_with_parent
    @taxon.protonym.authorship.reference ||= References::DefaultReference.get session
  end

  def create
    @taxon = build_taxon_with_parent

    TaxonForm.new(
      @taxon,
      taxon_params,
      taxon_name_string: params[:taxon_name_string].presence,
      protonym_name_string: params[:protonym_name_string].presence
    ).save

    @taxon.create_activity :create, edit_summary: params[:edit_summary]
    redirect_to catalog_path(@taxon), notice: "Taxon was successfully added." + add_another_species_link
  rescue ActiveRecord::RecordInvalid, Taxon::TaxonExists
    render :new
  end

  def edit
  end

  def update
    TaxonForm.new(@taxon, taxon_params).save

    @taxon.create_activity :update, edit_summary: params[:edit_summary]
    redirect_to catalog_path(@taxon), notice: "Taxon was successfully updated."
  rescue ActiveRecord::RecordInvalid, Taxon::TaxonExists
    render :edit
  end

  def destroy
    if @taxon.what_links_here predicate: true
      redirect_to taxon_what_links_here_path(@taxon), alert: <<~MSG
        Other taxa refer to this taxon, so it can't be deleted.
        Please see the table on this page for items referring to it.
      MSG
    else
      Taxon.transaction do
        UndoTracker.setup_change @taxon, :delete
        @taxon.taxon_state.update!(deleted: true, review_state: TaxonState::WAITING)
        @taxon.destroy!
        @taxon.create_activity :destroy, edit_summary: params[:edit_summary]
      end
      redirect_to catalog_path(@taxon.parent), notice: "Taxon was successfully deleted."
    end
  end

  private

    def set_taxon
      @taxon = Taxon.find(params[:id])
    end

    def add_another_species_link
      return "" unless @taxon.is_a? Species

      link = view_context.link_to "Add another #{@taxon.genus.name_html_cache} species?".html_safe,
        new_taxa_path(rank_to_create: "species", parent_id: @taxon.genus.id)

      " <strong>#{link}</strong>".html_safe
    end

    def taxon_params
      params.require(:taxon).permit(
        :status,
        :species_id,
        :protonym_id,
        { name_attributes: [:gender] },
        :homonym_replaced_by_id,
        :current_valid_taxon_id,
        :incertae_sedis_in,
        :fossil,
        :nomen_nudum,
        :unresolved_homonym,
        :ichnotaxon,
        :hong,
        :headline_notes_taxt,
        {
          protonym_attributes: [
            :fossil,
            :sic,
            :primary_type_information_taxt,
            :secondary_type_information_taxt,
            :type_notes_taxt,
            :locality,
            :id,
            { authorship_attributes: [:pages, :forms, :notes_taxt, :id, :reference_id] }
          ]
        },
        :type_taxon_id,
        :type_taxt,
        :biogeographic_region
      )
    end

    def build_taxon_with_parent
      parent = Taxon.find(params[:parent_id])

      taxon = build_taxon params[:rank_to_create]
      taxon.parent = parent
      taxon
    end

    def build_taxon rank
      taxon_class = "#{rank}".titlecase.constantize

      taxon = taxon_class.new
      taxon.build_name
      taxon.build_protonym
      taxon.protonym.build_name
      taxon.protonym.build_authorship
      taxon
    end
end
