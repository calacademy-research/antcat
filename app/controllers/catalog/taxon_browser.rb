module Catalog
  class TaxonBrowser
    attr_accessor :panels, :self_and_parents, :display

    def initialize the_taxon, show_invalid, display_param
      @the_taxon = the_taxon
      @show_invalid = show_invalid
      @display =  case the_taxon
                  when Subfamily
                    "all_genera_in_subfamily"
                  when Subgenus
                    "subgenera_in_parent_genus"
                  else
                    display_param
                  end

      @self_and_parents = self_and_parents_secret
      setup_panels
    end

    def show_invalid?
      @show_invalid
    end

    def selected_in_panel? taxon
      taxon.in? @self_and_parents
    end

    def panel_open? panel
      panels.last == panel
    end

    private
      def setup_panels
        @panels = main_progression_taxa.map do |taxon|
          StandardPanel.new(taxon, self)
        end

        extra_panel = non_standard_panel
        @panels << extra_panel if extra_panel
      end

      # The "main progression", from the lowest rank and up is: Subspecies ->
      # Species -> Genus -> Tribe -> Subfamily -> Family.
      # See https://github.com/calacademy-research/antcat/wiki/For-developers
      def main_progression_taxa
        # We do not want to include all ranks in the panels.
        self_and_parents.reject do |taxon|
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
        end
      end

      # TODO improve.
      def non_standard_panel
        return unless @display

        case @display
        when /^incertae_sedis_in/
          title = "Genera <i>incertae sedis</i> in #{@the_taxon.taxon_label}"
          children = @the_taxon.genera_incertae_sedis_in
        when /^all_genera_in/
          title = "All #{@the_taxon.taxon_label} genera"
          children = @the_taxon.all_displayable_genera
        when "all_taxa_in_genus"
          title = "All #{@the_taxon.taxon_label} taxa"
          children = @the_taxon.displayable_child_taxa
        when "subgenera_in_genus"
          title = "#{@the_taxon.taxon_label} subgenera"
          children = @the_taxon.displayable_subgenera
        when "subgenera_in_parent_genus"
          # Works because [currently] all subgenera have parents.
          title = "#{@the_taxon.parent.taxon_label} subgenera"
          children = @the_taxon.parent.displayable_subgenera
        end

        SpecialPanel.new title.html_safe, children, self
      end

      def self_and_parents_secret
        parents = []
        current_taxon = @the_taxon

        while current_taxon
          parents << current_taxon
          current_taxon = current_taxon.parent
        end

        # Reversed to put Formicidae in the first panel and itself in last.
        parents.reverse
      end
  end
end

class TaxonBrowserPanel
  attr_accessor :taxon # TODO move to `StandardPanel`.
  delegate :display, :selected_in_panel?, :panel_open?, to: :@taxon_browser

  def initialize children, taxon_browser
    @taxon_browser = taxon_browser

    @children = if @taxon_browser.show_invalid?
                  children
                else
                  children.valid
                end
  end

  def each_child
    sorted_children.each do |child|
      yield child, selected_in_panel?(child)
    end
  end

  def open?
    panel_open? self
  end

  def notify_about_no_valid_children?
    @children.empty? && !is_a_subfamily_with_valid_genera_incertae_sedis?
  end

  private
    # Exception for subfamilies *only* containing genera that are
    # incertae sedis in that subfamily (that is Martialinae, #430173).
    def is_a_subfamily_with_valid_genera_incertae_sedis?
      return unless @taxon.is_a? Subfamily
      @taxon.genera_incertae_sedis_in.valid.exists?
    end

    # "All taxa" (in genus) children must be sorted by `names.epithet`.
    def sorted_children
      if display == "all_taxa_in_genus"
        @children.order_by_joined_epithet
      else
        @children.order_by_name_cache
      end.includes(:name)
    end
end

class StandardPanel < TaxonBrowserPanel
  def initialize taxon, taxon_browser
    @taxon = taxon

    children = taxon.children.displayable
    super children, taxon_browser
  end

  def title
    return @taxon.taxon_label if show_only_genus_name?
    "#{@taxon.taxon_label} #{@taxon.childrens_rank_in_words}".html_safe
  end

  private
    # For the "All taxa" and "Subgenera" special cases, because
    # this would be confusing/false:
    #   "Formicidae ... Lasius species > Lasius subgenera"
    #   "Formicidae ... Lasius species > All Lasius taxa"
    def show_only_genus_name?
      return unless @taxon.is_a? Genus
      display.in? %w( all_taxa_in_genus
                      subgenera_in_genus
                      subgenera_in_parent_genus )
    end
end

class SpecialPanel < TaxonBrowserPanel
  def initialize title, children, taxon_browser
    super children, taxon_browser
    @title = title
  end

  def title
    @title
  end
end
