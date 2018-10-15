# This controller handles editing by logged in editors.
# `CatalogController` is responsible for showing taxon pages to users.

class TaxaController < ApplicationController
  before_action :ensure_can_edit_catalog
  before_action :set_previous_combination, only: [:new, :create]
  before_action :set_taxon, only: [:edit, :update]

  def new
    @taxon = build_taxon_with_parent

    if @previous_combination
      set_attributes_from_previous_combination
    else
      @taxon.protonym.authorship.reference ||= DefaultReference.get session
    end
  end

  def create
    @taxon = build_taxon_with_parent

    if @previous_combination
      set_attributes_from_previous_combination

      if blank_or_homonym_collision_resolution?
        create_new_combination!
        redirect_to catalog_path(@taxon), notice: "Successfully created combination."
      else
        original_combination = save_original_combination!
        redirect_to catalog_path(original_combination), notice: "Taxon was return to a previous usage."
      end
    else
      TaxonForm.new(@taxon, taxon_params).save
      @taxon.create_activity :create, edit_summary: params[:edit_summary]
      redirect_to catalog_path(@taxon), notice: "Taxon was successfully added." + add_another_species_link
    end
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

    def set_previous_combination
      return if params[:previous_combination_id].blank?
      @previous_combination = Taxon.find(params[:previous_combination_id])
    end

    # `collision_resolution` will be a taxon ID, "homonym" or blank.
    def blank_or_homonym_collision_resolution?
      params[:collision_resolution].blank? || params[:collision_resolution] == 'homonym'
    end

    def create_new_combination!
      TaxonForm.new(@taxon, taxon_params, @previous_combination).save

      @taxon.create_activity :create_combination, edit_summary: params[:edit_summary],
        parameters: {
          name: @taxon.name_html_cache,
          previous_combination_id: @previous_combination.id,
          previous_combination_name: @previous_combination.name_html_cache
        }
    end

    def save_original_combination!
      original_combination = Taxon.find(params[:collision_resolution])
      TaxonForm.new(original_combination, taxon_params, @previous_combination).save

      original_combination.create_activity :return_combination_to_previous_usage,
        edit_summary: params[:edit_summary],
        parameters: {
          name: original_combination.name_html_cache,
          previous_combination_id: @previous_combination.id,
          previous_combination_name: @previous_combination.name_html_cache
        }

      original_combination
    end

    def add_another_species_link
      return "" unless @taxon.is_a?(Species) && @taxon.genus

      link = view_context.link_to "Add another #{@taxon.genus.name_html_cache} species?".html_safe,
        new_taxa_path(rank_to_create: "species", parent_id: @taxon.genus.id)

      " <strong>#{link}</strong>".html_safe
    end

    def taxon_params
      params.require(:taxon).permit(
        :status,
        :species_id,
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
        { type_name_attributes: [:id] },
        :type_fossil,
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
      taxon.build_type_name
      taxon.build_protonym
      taxon.protonym.build_name
      taxon.protonym.build_authorship
      taxon
    end

    def set_attributes_from_previous_combination
      if params[:collision_resolution]
        if blank_or_homonym_collision_resolution?
          @taxon.unresolved_homonym = true
          @taxon.status = Status::HOMONYM
        end
      end

      @taxon.inherit_attributes_for_new_combination @previous_combination, @taxon.parent
    end
end
