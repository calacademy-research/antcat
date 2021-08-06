# frozen_string_literal: true

class CatalogPresenter
  attr_private_initialize :taxon, [:params, :session, { formicidae_landing_page: false }]

  def taxon_browser
    @_taxon_browser ||= TaxonBrowser::Browser.new(taxon, session[:show_invalid], params[:view]&.to_sym)
  end

  def taxon_browser_presenter
    @_taxon_browser_presenter ||= TaxonBrowserPresenter.new(taxon_browser)
  end

  def formatted_statistics
    @_formatted_statistics ||= Taxa::Statistics::FormatStatistics[fetch_statistics]
  end

  def show_full_statistics?
    return true if params[:include_full_statistics].present?
    !taxon.valid_status?
  end

  # NOTE: Special case to avoid showing ~6 A4 pages of Formicidae references and use a different title.
  def formicidae_landing_page?
    formicidae_landing_page
  end

  def collected_references
    Taxa::CollectReferences[taxon].order_by_author_names_and_year.includes(:document)
  end

  private

    def fetch_statistics
      if show_full_statistics?
        full_statistics
      else
        # If there's no valid-only stats, try including invalid too before giving up.
        valid_only_statistics || full_statistics
      end
    end

    def full_statistics
      Taxa::Statistics::FetchStatistics[taxon]
    end

    def valid_only_statistics
      Taxa::Statistics::FetchStatistics[taxon, valid_only: true]
    end
end
