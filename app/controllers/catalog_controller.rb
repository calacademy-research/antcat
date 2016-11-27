class CatalogController < ApplicationController
  unless Rails.env.production?
    # Avoid blowing up if there's no family. Useful in test and dev.
    before_action only: [:index] do
      render 'family_not_found' unless Family.exists?
      false
    end
  end
  before_action :setup_catalog, only: [:index, :show]

  def index
    render 'show'
  end

  def show
  end

  # This is basically "def toggle_show_invalid", because that is
  # currently the only "option". Maybe rename.
  def options
    # The param in "catalog/options?show_invalid=true" doesn't do anything,
    # it's only for making the URL more intuitive to users.
    session[:show_invalid] = !session[:show_invalid]
    redirect_to :back
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

  # Secret page. Append "/wikipedia" after the taxon id.
  def wikipedia_tools
    @taxon = Taxon.find params[:id]
    @authorship_reference = @taxon.send :authorship_reference
  end

  private
    def setup_catalog
      set_taxon
      setup_panels
    end

    def set_taxon
      @taxon = params[:id] ? Taxon.find(params[:id]) : Family.first
    end

    def setup_panels
      @self_and_parents = @taxon.self_and_parents

      @panels = @self_and_parents.reject do |taxon|
        # Never show the subspecies panel (has no children).
        taxon.is_a?(Subspecies) ||

        # Don't show species panel unless the species has subspecies.
        (taxon.is_a?(Species) && !taxon.children.exists?) ||

        # No subgenus panel (not part of the 'normal' rank hierarchy).
        taxon.is_a?(Subgenus)

        # Panels of subfamilies, tribes and genera without any children at
        # all could also be excluded here, to avoid showing empty panels.
        # However, that can only happen to invalid taxa (all valid taxa of
        # these ranks have children unless the database is incomplete), so
        # it makes more sense to just show "No valid child taxa".
      end.map do |taxon|
        children = taxon.children.displayable
        children = children.valid unless session[:show_invalid]
        { selected: taxon, children: children }
      end

      setup_non_standard_panels
    end

    def include_all_genera_in_subfamily
      if @taxon.is_a? Subfamily
        params[:display] = "all_genera_in_subfamily"
      end
    end

    def setup_non_standard_panels
      include_all_genera_in_subfamily if params[:display].blank?
      subgenera_special_case
      return unless params[:display]

      case params[:display]
      when /^incertae_sedis_in/
        title = "Genera <i>incertae sedis</i> in #{@taxon.name_html_cache}"
        children = @taxon.genera_incertae_sedis_in
      when /^all_genera_in/
        title = "All #{@taxon.name_html_cache} genera"
        children = @taxon.all_displayable_genera
      when "all_taxa_in_genus"
        title = "All #{@taxon.name_html_cache} taxa"
        children = @taxon.displayable_child_taxa
      when "subgenera_in_genus"
        title = "#{@taxon.name_html_cache} subgenera"
        children = @taxon.displayable_subgenera
      when "subgenera_in_parent_genus"
        # Works because [currently] all subgenera have parents.
        title = "#{@taxon.parent.name_html_cache} subgenera"
        children = @taxon.parent.displayable_subgenera
      end

      children = children.valid unless session[:show_invalid]
      @panels << { selected: { title_for_panel: title },
                  children: children }
    end

    # Enables the subgenera panel when subgenera are selected.
    def subgenera_special_case
      if @taxon.is_a? Subgenus
        params[:display] = "subgenera_in_parent_genus"
      end
    end
end
