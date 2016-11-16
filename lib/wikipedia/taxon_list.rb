# Class for generating wiki-formatted lists of tribes, genera and species.

module Wikipedia
  class TaxonList
    def initialize taxon
      @taxon = taxon
    end

    def children
      case @taxon
      when Family, Tribe then genera
      when Subfamily     then genera << divider << tribes
      when Genus         then species
      else               "cannot generate children list for this taxon"
      end
    end

    def tribes
      generate :tribes
    end

    def genera
      generate :genera
    end

    def species
      generate :species
    end

    private
      def generate rank
        set_children rank

        output = taxobox_extras
        output << "\n"
        output << list_header

        @children.each { |child| output << format_child(child) }

        output << list_footer
        output
      end

      def set_children rank
        @children_rank = rank
        @children = @taxon.send(@children_rank).valid.order_by_name_cache
      end

      def divider
        "\n-------------------\n\n"
      end

      # For https://en.wikipedia.org/wiki/Template:Taxobox
      def taxobox_extras
        diversity_ref = Wikipedia::CiteTemplate.with_ref_tag @taxon
        children_count = @children.count

        string =  "|diversity_link = ##{@children_rank.to_s.capitalize}\n"
        string << "|diversity = #{children_count} #{@children_rank}\n"
        string << "|diversity_ref = #{diversity_ref}\n"
      end

      # "==Species== ..."
      def list_header
        "==#{@children_rank.to_s.capitalize}==\n{{div col||25em}}\n"
      end

      def list_footer
        "{{div col end}}\n"
      end

      # "* †''[[Atta mexicana]]'' <small>Author, 2005</small>\n"
      def format_child child
        line = "* "
        line << taxon_name(child)
        line << " "
        line << author_citation(child)
        line << "\n"
        line
      end

      def taxon_name child
        name = child.name_cache
        name = "[[#{name}]]" if wikilink_child? child
        name = "''#{name}''" if italicize_name? child

        "#{dagger if child.fossil}#{name}"
      end

      def dagger
        "†"
      end

      def italicize_name? child
        child.class.in? [Genus, Species, Subspecies]
      end

      def wikilink_child? child
        # Don't link species in fossil genera per WP:PALEO.
        return if @taxon.fossil? && child.is_a?(Species)

        # Don't link subspecies (we should not have article on these).
        return if child.is_a? Subspecies

        true
      end

      def author_citation child
        "<small>#{child.authorship_string}</small>"
      end
  end
end
