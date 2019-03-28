# This controller handles editing by logged in editors.
# `CatalogController` is responsible for showing taxon pages to users.

class TaxaController < ApplicationController
  before_action :ensure_can_edit_catalog
  before_action :set_taxon, only: [:edit, :update]

  def new
    @taxon = build_taxon_with_parent
    @taxon.protonym.authorship.reference ||= DefaultReference.get session
  end

  def create
    @taxon = build_taxon_with_parent

    TaxonForm.new(@taxon, taxon_params).save
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
        { name_attributes: [:id, :gender] },
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
            :locality,
            :name_id,
            :id,
            { name_attributes: [:id] },
            {
              authorship_attributes: [
                :pages,
                :forms,
                :notes_taxt,
                :id,
                :reference_id
              ]
            }
          ]
        },
        :type_taxon_id,
        :type_taxt,
        :biogeographic_region,
        :primary_type_information,
        :secondary_type_information,
        :type_notes
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
