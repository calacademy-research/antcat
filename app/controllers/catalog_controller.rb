class CatalogController < ApplicationController
  before_action :set_taxon, only: [:show, :wikipedia_tools]

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
    q = params[:q] || ''

    # See if we have an exact ID match.
    search_results = if q =~ /^\d{6} ?$/
                       id_matches_q = Taxon.find_by id: q
                       [id_matches_q] if id_matches_q
                     end

    search_results ||= Taxon.where("name_cache LIKE ?", "%#{q}%")
      .includes(:name, protonym: { authorship: :reference }).take(10)

    respond_to do |format|
      format.json do
        results = search_results.map do |taxon|
          { id: taxon.id,
            name: taxon.name_html_cache,
            authorship_string: taxon.authorship_string }
        end
        render json: results
      end
    end
  end

  private
    def set_taxon
      @taxon = Taxon.find params[:id]
    end

    def setup_taxon_browser
      @taxon_browser = Catalog::TaxonBrowser::Browser.new @taxon,
        session[:show_invalid], params[:display].try(:to_sym)
    end
end
