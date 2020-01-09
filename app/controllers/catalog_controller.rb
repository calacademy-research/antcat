class CatalogController < ApplicationController
  before_action :set_taxon, only: [:show, :tab]

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

    @editor_taxon_view_object = EditorTaxonViewObject.new(@taxon)
    setup_taxon_browser

    render 'show'
  end

  def show
    @editor_taxon_view_object = EditorTaxonViewObject.new(@taxon)
    setup_taxon_browser
  end

  def tab
    respond_to do |format|
      format.json do
        setup_taxon_browser

        tab = @taxon_browser.tab_by_id params[:tab_id]
        render partial: "taxon_browser/tab", locals: { tab: tab, cap: false }
      end
    end
  end

  private

    def set_taxon
      @taxon = Taxon.eager_load(:name, :taxon_state, protonym: [:name, { authorship: :reference }]).find(params[:id])
    end

    def setup_taxon_browser
      @taxon_browser = TaxonBrowser::Browser.new @taxon, session[:show_invalid], params[:display]&.to_sym
    end
end
