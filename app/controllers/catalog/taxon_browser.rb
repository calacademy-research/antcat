module Catalog
  class TaxonBrowser
    attr_accessor :tabs, :display

    def initialize taxon, show_invalid, display_param
      @taxon = taxon
      @show_invalid = show_invalid
      @display =  case taxon
                  when Subfamily
                    "all_genera_in_subfamily" # TODO only if blank.
                  when Subgenus
                    "subgenera_in_parent_genus"
                  else
                    display_param
                  end

      setup_tabs
    end

    def show_invalid?
      @show_invalid
    end

    def selected_in_tab? taxon
      taxon.in? selected_in_tabs
    end

    def tab_open? tab
      @tabs.last == tab
    end

    private
      def setup_tabs
        @tabs = taxa_for_tabs.map do |taxon|
          TaxonTab.new(taxon, self)
        end

        extra_tab = non_standard_tab
        @tabs << extra_tab if extra_tab
      end

      # The "main progression", from the lowest rank and up is: Subspecies ->
      # Species -> Genus -> Tribe -> Subfamily -> Family.
      # See https://github.com/calacademy-research/antcat/wiki/For-developers
      def taxa_for_tabs
        # We do not want to include all ranks in the tabs.
        selected_in_tabs.reject do |taxon|
          # Never show the [children of] subspecies tab (has no children).
          taxon.is_a?(Subspecies) ||

          # Don't show [children of] species tab unless the species has subspecies.
          (taxon.is_a?(Species) && !taxon.children.exists?) ||

          # No [children of] subgenus tab (not part of the 'normal' rank hierarchy).
          taxon.is_a?(Subgenus)

          # Tabs of subfamilies, tribes and genera without any children at
          # all could also be excluded here, to avoid showing empty tabs.
          # However, that can only happen to invalid taxa (all valid taxa of
          # these ranks have children unless the database is incomplete), so
          # it makes more sense to just show "No valid child taxa".
        end
      end

      # TODO improve.
      def non_standard_tab
        return unless @display

        case @display
        when /^incertae_sedis_in/
          title = "Genera <i>incertae sedis</i> in #{@taxon.taxon_label}"
          children = @taxon.genera_incertae_sedis_in
        when /^all_genera_in/
          title = "All #{@taxon.taxon_label} genera"
          children = @taxon.all_displayable_genera
        when "all_taxa_in_genus"
          title = "All #{@taxon.taxon_label} taxa"
          children = @taxon.displayable_child_taxa
        when "subgenera_in_genus"
          title = "#{@taxon.taxon_label} subgenera"
          children = @taxon.displayable_subgenera
        when "subgenera_in_parent_genus"
          # Works because [currently] all subgenera have parents.
          title = "#{@taxon.parent.taxon_label} subgenera"
          children = @taxon.parent.displayable_subgenera
        end

        ExtraTab.new title.html_safe, children, self
      end

      def selected_in_tabs
        @selected_in_tabs ||= taxon_and_parents
      end

      def taxon_and_parents
        parents = []
        current_taxon = @taxon

        while current_taxon
          parents << current_taxon
          current_taxon = current_taxon.parent
        end

        # Reversed to put Formicidae in the first tab and itself in last.
        parents.reverse
      end
  end
end

class TaxonBrowserTab
  attr_accessor :tab_taxon
  delegate :display, :selected_in_tab?, :tab_open?, :show_invalid?,
    to: :@taxon_browser

  def initialize children, taxon_browser
    @taxon_browser = taxon_browser

    @children = if show_invalid?
                  children
                else
                  children.valid
                end
  end

  def each_child
    sorted_children.each do |child|
      yield child, selected_in_tab?(child)
    end
  end

  def open?
    tab_open? self
  end

  def notify_about_no_valid_children?
    @children.empty? && !is_a_subfamily_with_valid_genera_incertae_sedis?
  end

  private
    # Exception for subfamilies *only* containing genera that are
    # incertae sedis in that subfamily (that is Martialinae, #430173).
    def is_a_subfamily_with_valid_genera_incertae_sedis?
      return unless @tab_taxon.is_a? Subfamily
      @tab_taxon.genera_incertae_sedis_in.valid.exists?
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

class TaxonTab < TaxonBrowserTab
  def initialize tab_taxon, taxon_browser
    @tab_taxon = tab_taxon

    children = tab_taxon.children.displayable
    super children, taxon_browser
  end

  def title
    return @tab_taxon.taxon_label if show_only_genus_name?
    "#{@tab_taxon.taxon_label} #{@tab_taxon.childrens_rank_in_words}".html_safe
  end

  private
    # For the "All taxa" and "Subgenera" special cases, because
    # this would be confusing/false:
    #   "Formicidae ... Lasius species > Lasius subgenera"
    #   "Formicidae ... Lasius species > All Lasius taxa"
    def show_only_genus_name?
      return unless @tab_taxon.is_a? Genus
      display.in? %w( all_taxa_in_genus
                      subgenera_in_genus
                      subgenera_in_parent_genus )
    end
end

class ExtraTab < TaxonBrowserTab
  def initialize title, children, taxon_browser
    super children, taxon_browser
    @title = title
  end

  def title
    @title
  end
end
