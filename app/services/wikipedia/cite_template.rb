# Class for generating Wikipedia {{AntCat}} citation templates.
# https://en.wikipedia.org/wiki/Template:AntCat

module Wikipedia
  class CiteTemplate
    include Service

    def initialize taxon, with_ref_tag: false
      @taxon = taxon
      @with_ref_tag = with_ref_tag
    end

    def call
      if with_ref_tag
        %(<ref name="AntCat">#{cite_template}</ref>)
      else
        cite_template
      end
    end

    private

      attr_reader :taxon, :with_ref_tag

      def cite_template
        <<-TEMPLATE.squish
           {{AntCat|#{taxon.id}|#{taxon_name}|#{year}|accessdate=#{accessdate}}}
        TEMPLATE
      end

      def taxon_name
        name = taxon.name_cache
        name = "''#{name}''" if taxon.class.in? [Genus, Species, Subspecies]

        "#{dagger if taxon.fossil?}#{name}"
      end

      def dagger
        "†"
      end

      def accessdate
        Time.zone.now.strftime "%-d %B %Y"
      end

      def year
        Time.zone.now.year
      end
  end
end
