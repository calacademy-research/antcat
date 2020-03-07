class CatalogController < ApplicationController
  before_action :set_taxon, only: [:show]

  # Avoid blowing up if there's no family. Useful in test and dev.
  unless Rails.env.production?
    before_action only: [:index] do
      render(inline: 'family_not_found', layout: true) unless Family.exists?
      false
    end
  end

  def index
    @taxon = Family.eager_load(:name, protonym: [:name, { authorship: :reference }]).first
    @catalog_presenter = CatalogPresenter.new(@taxon, params: params, session: session, formicidae_landing_page: true)
    @editors_taxon_view_object = Editors::TaxonViewObject.new(@taxon)

    render 'show'
  end

  def show
    @catalog_presenter = CatalogPresenter.new(@taxon, params: params, session: session)
    @editors_taxon_view_object = Editors::TaxonViewObject.new(@taxon)
  end

  private

    def set_taxon
      @taxon = Taxon.eager_load(:name, protonym: [:name, { authorship: :reference }]).find(params[:id])
    end
end
