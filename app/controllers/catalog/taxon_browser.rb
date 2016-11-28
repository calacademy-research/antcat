module Catalog
  class TaxonBrowser
    attr_accessor :tabs, :display

    def initialize taxon, show_invalid, display_param
      @taxon = taxon
      @show_invalid = show_invalid
      @display = default_or_display display_param

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
      def default_or_display display
        case @taxon
        when Subfamily then :all_genera_in_subfamily if display.blank?
        when Subgenus  then :subgenera_in_parent_genus
        end || display.try(:to_sym)
      end

      def setup_tabs
        @tabs = taxa_for_tabs.map do |taxon|
          TaxonTab.new(taxon, self)
        end

        extra_tab = ExtraTab.create @taxon, @display, self
        @tabs << extra_tab if extra_tab
      end

      # Follows the "main progression", which from the lowest rank and up is:
      # Subspecies -> Species -> Genus -> Tribe -> Subfamily -> Family.
      # See https://github.com/calacademy-research/antcat/wiki/For-developers
      def taxa_for_tabs
        # We do not want to include all ranks in the tabs.
        selected_in_tabs.reject do |taxon|
          # Never show the [children of] subspecies tab (has no children).
          taxon.is_a?(Subspecies) ||

          # Don't show [subspecies in] species tab unless the species has subspecies.
          (taxon.is_a?(Species) && !taxon.children.exists?) ||

          # Hide [species in] subgenus tab because there are none as of 2016.
          taxon.is_a?(Subgenus)
        end
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
    sorted_children.includes(:name).each do |child|
      yield child, selected_in_tab?(child)
    end
  end

  def open?
    tab_open? self
  end

  private
    def sorted_children
      @children.order_by_name_cache
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

    # Tweak for the [species of] genus tab to change eg
    # "Lasius species > Lasius subgenera" to "Lasius > Lasius subgenera".
    def show_only_genus_name?
      return unless @tab_taxon.is_a? Genus
      display.in? [ :all_taxa_in_genus,
                    :subgenera_in_genus,
                    :subgenera_in_parent_genus ]
    end
end

class ExtraTab < TaxonBrowserTab
  def self.create taxon, display, taxon_browser
    return unless display

    label = taxon.taxon_label

    title, children = case display
      when :incertae_sedis_in_family, :incertae_sedis_in_subfamily
        [ "Genera <i>incertae sedis</i> in #{label}",
          taxon.genera_incertae_sedis_in ]
      when :all_genera_in_family, :all_genera_in_subfamily
        [ "All #{label} genera", taxon.all_displayable_genera ]
      when :all_taxa_in_genus
        [ "All #{label} taxa", taxon.displayable_child_taxa ]
      when :subgenera_in_genus
        [ "#{label} subgenera", taxon.displayable_subgenera ]
      when :subgenera_in_parent_genus
        [ "#{taxon.genus.taxon_label} subgenera",
          taxon.genus.displayable_subgenera ]
      else
        raise
      end

    new title, children, taxon_browser
  end

  def initialize title, children, taxon_browser
    super children, taxon_browser
    @title = title.html_safe
  end

  def title
    @title
  end

  def notify_about_no_valid_children?
    false
  end

  private
    ## "All taxa" in genus must be sorted by `names.epithet`.
    def sorted_children
      return @children.order_by_joined_epithet if display == :all_taxa_in_genus
      super
    end
end
