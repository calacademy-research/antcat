class CatalogController < ApplicationController
  before_action :set_taxon, only: [:show, :tab, :wikipedia_tools]

  # Avoid blowing up if there's no family. Useful in test and dev.
  unless Rails.env.production?
    before_action only: [:index] do
      render 'family_not_found' unless Family.exists?
      false
    end
  end

  def index
    @taxon = Family.first

    setup_taxon_browser
    render 'show'
  end

  def show
    setup_taxon_browser
  end

  def tab
    respond_to do |format|
      format.json do
        setup_taxon_browser

        tab = @taxon_browser.tab_by_id params[:tab_id]
        render partial: "taxon_browser_tab_taxa", locals: { tab: tab, cap: false }
      end
    end
  end

  # TODO use cookies instead of session.
  def show_valid_only
    session[:show_invalid] = false
    redirect_to :back
  end

  def show_invalid
    session[:show_invalid] = true
    redirect_to :back
  end

  # Secret page. Append "/wikipedia" after the taxon id.
  def wikipedia_tools
  end

  def autocomplete
    search_query = params[:q] || ''

    respond_to do |format|
      format.json do
        render json: Autocomplete::AutocompleteTaxa[search_query]
      end
    end
  end

  private
    def set_taxon
      @taxon = Taxon.find params[:id]
    end

    def setup_taxon_browser
      @taxon_browser = TaxonBrowser::Browser.new @taxon,
        session[:show_invalid], params[:display].try(:to_sym)
    end
end
