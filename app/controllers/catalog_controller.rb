# frozen_string_literal: true

# The catalog of the family Formicidae.
#
# Routes: GET / (anyone); GET /catalog/:id (anyone). Purpose, rights and tests of each: docs/catalog/routes.tsv.
class CatalogController < ApplicationController
  # Avoid blowing up if there's no family. Useful in test and dev.
  unless Rails.env.production?
    before_action only: [:index] do
      render(html: 'family_not_found', layout: true) unless Family.exists?
      false
    end
  end

  def index
    @taxon = Family.eager_load(:name, protonym: [:name, { authorship: :reference }]).first
    @protonym = @taxon.protonym
    @catalog_presenter = CatalogPresenter.new(@taxon, params: params, session: session, formicidae_landing_page: true)
    @editors_catalog_presenter = Editors::CatalogPresenter.new(@taxon)

    render 'show'
  end

  def show
    @taxon = Taxon.eager_load(:name, protonym: [:name, { authorship: :reference }]).find(params.expect(:id))
    @protonym = @taxon.protonym
    @catalog_presenter = CatalogPresenter.new(@taxon, params: params, session: session)
    @editors_catalog_presenter = Editors::CatalogPresenter.new(@taxon)
  end
end
