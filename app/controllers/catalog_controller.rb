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
    @taxon = Family.eager_load(:name, :taxon_state, protonym: [:name, { authorship: :reference }]).first

    # NOTE: Special case to avoid showing ~6 A4 pages of Formicidae references and use a different title.
    @is_formicidae_landing_page = true

    @editors_taxon_view_object = Editors::TaxonViewObject.new(@taxon)
    setup_taxon_browser

    render 'show'
  end

  def show
    @editors_taxon_view_object = Editors::TaxonViewObject.new(@taxon)
    setup_taxon_browser
  end

  private

    def set_taxon
      @taxon = Taxon.eager_load(:name, :taxon_state, protonym: [:name, { authorship: :reference }]).find(params[:id])
    end

    def setup_taxon_browser
      @taxon_browser = TaxonBrowser::Browser.new @taxon, session[:show_invalid], params[:display]&.to_sym
    end
end
