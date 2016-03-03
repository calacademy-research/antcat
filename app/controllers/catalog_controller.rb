class CatalogController < ApplicationController
  before_filter :set_session, only: [:index, :show]
  before_filter :handle_family_not_found, only: [:index]
  before_filter :set_taxon, only: [:index, :show]
  before_filter :setup_panels, only: [:index, :show]
  before_filter :enable_taxon_toggler, only: [:index, :show]

  def index
    render 'show'
  end

  def show
  end

  def quick_search
    @search_results = Taxa::Search.find_name(params[:qq], params[:search_type])
      .paginate(page: params[:page])

    # Single match --> skip search results and just show the match
    if @search_results && @search_results.count == 1
      taxon = @search_results.first
      return redirect_to catalog_path(taxon)
    end

    render "search"
  end

  def options
    # params[:valid_only] is only for making the URL more intuitive
    session[:show_valid_only] = !session[:show_valid_only]
    redirect_to :back
  end

  private
    # Avoid blowing up if there's no family. Useful in test and dev.
    def handle_family_not_found
      render 'family_not_found' and return unless Family.first
    end

    # TODO reverse name, so that this is not needed
    def set_session
      session[:show_valid_only] = true if session[:show_valid_only].nil?
    end

    def set_taxon
      @taxon =  if params[:id]
                  Taxon.find(params[:id])
                else
                  Family.first
                end
    end

    def setup_panels
      @self_and_parents = @taxon.self_and_parents

      @panels = @self_and_parents.reject do |taxon|
        # never show the subspecies panel (has no children)
        taxon.is_a?(Subspecies) ||
        # don't show species panel unless the species has subspecies
        (taxon.is_a?(Species) && taxon.children.empty?)
      end.map do |taxon|
        children = taxon.children.displayable.ordered_by_name
        children = children.valid if session[:show_valid_only]
        { selected: taxon, children: children }
      end

      setup_non_standard_panels
    end

    def setup_non_standard_panels
      return unless params[:display]

      case params[:display]
      when /^incertae_sedis_in/
        title = "Genera <i>incertae sedis</i> in #{@taxon.name_html_cache}"
        children = @taxon.genera_incertae_sedis_in
      when /^all_genera_in/
        title = "All #{@taxon.name_cache} genera"
        children = @taxon.all_displayable_genera
      end

      children = children.valid if session[:show_valid_only]
      @panels << { selected: { title_for_panel: title },
                  children: children }
    end

    def enable_taxon_toggler
      @display_taxon_toggler = true
    end

end
