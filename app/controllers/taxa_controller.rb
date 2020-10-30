# frozen_string_literal: true

# This controller handles editing by logged in editors.
# `CatalogController` is responsible for showing taxon pages to users.

class TaxaController < ApplicationController
  before_action :ensure_user_is_editor

  def new
    @taxon = build_taxon(params[:rank_to_create], params[:parent_id])
    @taxon.protonym.authorship.reference ||= References::DefaultReference.get(session)
    @default_name_string = params[:taxon_name_string] || Taxa::PrefilledTaxonFormName[@taxon]
  end

  def create
    @taxon = build_taxon(params[:rank_to_create], params[:parent_id])

    @taxon_form = TaxonForm.new(
      @taxon,
      taxon_params,
      taxon_name_string: params[:taxon_name_string],
      protonym_name_string: params[:protonym_name_string].presence
    )

    if @taxon_form.save
      @taxon.create_activity :create, current_user, edit_summary: params[:edit_summary]
      redirect_to catalog_path(@taxon), notice: "Taxon was successfully added." + add_another_species_link
    else
      render :new
    end
  end

  def edit
    @taxon = find_taxon
  end

  def update
    @taxon = find_taxon

    if @taxon.update(taxon_params)
      @taxon.create_activity :update, current_user, edit_summary: params[:edit_summary]
      redirect_to catalog_path(@taxon), notice: "Taxon was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    taxon = find_taxon

    if taxon.what_links_here.any?
      redirect_to taxon_what_links_here_path(taxon), alert: "Other records refer to this taxon, so it can't be deleted."
      return
    end

    if taxon.destroy
      taxon.create_activity :destroy, current_user
      redirect_to catalog_path(taxon.parent), notice: "Taxon was successfully deleted."
    else
      redirect_to catalog_path(taxon.parent), alert: taxon.errors.full_messages.to_sentence
    end
  end

  private

    def find_taxon
      Taxon.find(params[:id])
    end

    def taxon_params
      params.require(:taxon).permit(
        :collective_group_name,
        :current_taxon_id,
        :fossil,
        :homonym_replaced_by_id,
        :hong,
        :incertae_sedis_in,
        :original_combination,
        :protonym_id,
        :status,
        :unresolved_homonym,
        name_attributes: [:gender],
        protonym_attributes: [
          *ProtonymForm::ATTRIBUTES.map(&:to_sym),
          { authorship_attributes: [:pages, :reference_id] }
        ]
      )
    end

    def prefilled_taxon_params
      params.permit(:current_taxon_id, :protonym_id, :status, :fossil, :original_combination)
    end

    def prefilled_authorship_params
      params.permit(authorship_attributes: [:pages, :reference_id]).fetch(:authorship_attributes, {})
    end

    def build_taxon rank_to_create, parent_id
      parent = Taxon.find(parent_id)

      Taxa::BuildTaxon[
        rank_to_create,
        parent,
        taxon_params: prefilled_taxon_params,
        authorship_params: prefilled_authorship_params
      ]
    end

    def add_another_species_link
      return "" unless @taxon.is_a? Species

      link = view_context.link_to "Add another #{@taxon.genus.name.name_html} species?".html_safe,
        new_taxa_path(rank_to_create: Rank::SPECIES, parent_id: @taxon.genus.id)

      " <strong>#{link}</strong>".html_safe
    end
end
