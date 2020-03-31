# frozen_string_literal: true

class CatalogPresenter
  def initialize taxon, params:, session:, formicidae_landing_page: false
    @taxon = taxon
    @params = params
    @session = session
    @formicidae_landing_page = formicidae_landing_page
  end

  def taxon_browser
    @_taxon_browser ||= TaxonBrowser::Browser.new(taxon, session[:show_invalid], params[:display]&.to_sym)
  end

  def statistics
    @_statistics ||= begin
      if show_full_statistics?
        taxon.decorate.statistics
      else
        # If there's no valid-only stats, try including invalid too before giving up.
        taxon.decorate.statistics(valid_only: true) || taxon.decorate.statistics
      end
    end
  end

  def show_full_statistics?
    taxon.invalid? || params[:include_full_statistics].present?
  end

  # NOTE: Special case to avoid showing ~6 A4 pages of Formicidae references and use a different title.
  def formicidae_landing_page?
    formicidae_landing_page
  end

  private

    attr_reader :taxon, :params, :session, :formicidae_landing_page
end
