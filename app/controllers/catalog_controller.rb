# frozen_string_literal: true

class CatalogController < ApplicationController
  # Avoid blowing up if there's no family. Useful in test and dev.
  unless Rails.env.production?
    before_action only: [:index] do
      render(inline: 'family_not_found', layout: true) unless Family.exists? # rubocop:disable Rails/RenderInline
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
    @taxon = Taxon.eager_load(:name, protonym: [:name, { authorship: :reference }]).find(params[:id])
    @protonym = @taxon.protonym
    @catalog_presenter = CatalogPresenter.new(@taxon, params: params, session: session)
    @editors_catalog_presenter = Editors::CatalogPresenter.new(@taxon)
  end
end
