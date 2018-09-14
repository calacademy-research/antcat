# This controller handles editing by logged in editors.
# `CatalogController` is responsible for showing taxon pages to users.

class TaxaController < ApplicationController
  before_action :ensure_can_edit_catalog
  before_action :set_previous_combination, only: [:new, :create, :edit, :update]
  before_action :set_taxon, only: [:edit, :update]

  def new
    @taxon = get_taxon_for_create
    set_authorship_reference
  end

  def create
    @taxon = get_taxon_for_create
    save_taxon

    @taxon.create_activity :create, edit_summary: params[:edit_summary]

    flash[:notice] = "Taxon was successfully added."

    show_add_another_species_link = @taxon.id && @taxon.is_a?(Species) && @taxon.genus
    if show_add_another_species_link
      link = view_context.link_to "Add another #{@taxon.genus.name_html_cache} species?".html_safe,
        new_taxa_path(rank_to_create: "species", parent_id: @taxon.genus.id)
      flash[:notice] += " <strong>#{link}</strong>".html_safe
    end

    redirect_to catalog_path(@taxon)
  rescue ActiveRecord::RecordInvalid, Taxon::TaxonExists
    render :new
  end

  def edit
  end

  def update
    save_taxon

    @taxon.create_activity :update, edit_summary: params[:edit_summary]
    redirect_to catalog_path(@taxon), notice: "Taxon was successfully updated."
  rescue ActiveRecord::RecordInvalid, Taxon::TaxonExists
    render :edit
  end

  private

    def set_previous_combination
      return if params[:previous_combination_id].blank?
      @previous_combination = Taxon.find(params[:previous_combination_id])
    end

    def set_taxon
      @taxon = Taxon.find(params[:id])
    end

    def get_taxon_for_create
      parent = Taxon.find(params[:parent_id])

      taxon = build_new_taxon params[:rank_to_create]
      taxon.parent = parent

      # Radio button case - we got duplicates, and the user picked one
      # to resolve the problem.
      collision_resolution = params[:collision_resolution]
      if collision_resolution
        if collision_resolution == 'homonym' || collision_resolution.blank?
          taxon.unresolved_homonym = true
          taxon.status = Status::HOMONYM
        else
          taxon.collision_merge_id = collision_resolution
          # TODO `original_combination` is never used.
          original_combination = Taxon.find(collision_resolution)
          original_combination.inherit_attributes_for_new_combination @previous_combination, parent
        end
      end

      # TODO move to `Taxa::HandlePreviousCombination`?
      if @previous_combination
        taxon.inherit_attributes_for_new_combination @previous_combination, parent
      end

      taxon
    end

    def save_taxon
      # `collision_resolution` will be the taxon ID of the preferred taxon or "homonym".
      collision_resolution = params[:collision_resolution]
      if collision_resolution.blank? || collision_resolution == 'homonym'
        TaxonForm.new(@taxon, taxon_params, @previous_combination).save
      else
        # TODO I believe this is where we lose track of `@taxon.id` (see nil check in `#create`)
        original_combination = Taxon.find(collision_resolution)
        TaxonForm.new(original_combination, taxon_params, @previous_combination).save
      end

      if @previous_combination.is_a?(Species) && @previous_combination.children.exists?
        create_new_usages_for_subspecies
      end
    end

    # TODO looks like this isn't tested
    def create_new_usages_for_subspecies
      @previous_combination.children.valid.each do |t|
        new_child = Subspecies.new

        # Only building type_name because all other will be copied from 't'.
        # TODO Not sure why type_name is not copied?
        new_child.build_type_name
        new_child.parent = @taxon

        new_child.inherit_attributes_for_new_combination t, @taxon
        TaxonForm.new(new_child, Taxa::AttributesForNewUsage[new_child, t], t).save
      end
    end

    def set_authorship_reference
      @taxon.protonym.authorship.reference ||= DefaultReference.get session
    end

    def taxon_params
      params.require(:taxon).permit(
        :status,
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
        { parent_name_attributes: [:id] },
        { type_name_attributes: [:id] },
        :type_fossil,
        :type_taxt,
        :biogeographic_region,
        :primary_type_information,
        :secondary_type_information,
        :type_notes
      )
    end

    def build_new_taxon rank
      taxon_class = "#{rank}".titlecase.constantize

      taxon = taxon_class.new
      taxon.build_name
      taxon.build_type_name
      taxon.build_protonym
      taxon.protonym.build_name
      taxon.protonym.build_authorship
      taxon
    end
end
