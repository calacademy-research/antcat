# Class for generating Wikipedia {{AntCat}} citation templates.
# https://en.wikipedia.org/wiki/Template:AntCat

module Wikipedia
  class CiteTemplate
    def self.generate taxon
      <<-TEMPLATE.squish
         {{AntCat|#{taxon.id}|#{taxon_name(taxon)}|#{year}|accessdate=#{accessdate}}}
      TEMPLATE
    end

    def self.with_ref_tag taxon
      %{<ref name="AntCat">#{generate(taxon)}</ref>}
    end

    private
      def self.taxon_name taxon
        name = taxon.name_cache
        name = "''#{name}''" if taxon.class.in? [Genus, Species, Subspecies]

        "#{dagger if taxon.fossil}#{name}"
      end

      def self.dagger
        "†"
      end

      def self.accessdate
        Time.zone.now.strftime "%-d %B %Y"
      end

      def self.year
        Time.zone.now.year
      end
  end
end
