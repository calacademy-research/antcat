module DatabaseScripts
  class TaxaWithTypeTaxa < DatabaseScript
    def results
      Taxon.where.not(type_taxon_id: nil).includes(type_taxon: :name)
    end

    def render
      as_table do |t|
        t.header :taxon, :status,
          :type_taxon, :type_taxt, :tt_status,
          :tt_expansion, :failed_tt_expansion,
          :type_taxon_now_if_different, :ttn_status
        t.rows do |taxon|
          type_taxon = taxon.type_taxon
          type_taxon_now = type_taxon.now
          tt_same_as_ttn = type_taxon == type_taxon_now

          type_taxon_expander = TypeTaxonExpander.new(taxon)

          [
            markdown_taxon_link(taxon),
            taxon.status,

            markdown_taxon_link(type_taxon),
            format_type_taxt(taxon.type_taxt),
            type_taxon.status,

            format_type_taxon_expansion(type_taxon_expander),
            type_taxon_expander.reason_cannot_expand,

            (markdown_taxon_link(type_taxon_now) unless tt_same_as_ttn),
            (type_taxon_now.status unless tt_same_as_ttn)
          ]
        end
      end
    end

    private

      def format_type_taxt type_taxt
        return '<span class="hidden-sort">1</span>' unless type_taxt

        return '<span class="hidden-sort">2</span>M' if type_taxt == Protonym::BY_MONOTYPY
        return '<span class="hidden-sort">3</span>OD' if type_taxt == Protonym::BY_ORIGINAL_DESIGNATION
        return '<span class="hidden-sort">4</span>SD' if type_taxt =~ Protonym::BY_ORIGINAL_SUBSEQUENT_DESIGNATION_OF

        Detax[type_taxt]
      end

      def format_type_taxon_expansion type_taxon_expander
        if type_taxon_expander.expansion == ''
          '[blank]'
        else
          type_taxon_expander.expansion
        end
      end
  end
end

__END__

category: Catalog
tags: [list, slow]

description: >
  This script was added to investigate automatic "now links" for type taxa.


  `type_taxon.now` is a new experimental function for resolving taxa.


  "CVT of TT if different from TTN" = `current_valid_taxon` of `type_taxon` if different from `type_taxon.now`


  Common `type_taxt`s ("by monotypy", "by original designation" and "by subsequent designation of ...") are abbreviated.

related_scripts:
  - TaxaWithTypeTaxa
  - TaxaWithTypeTaxt
  - TaxaWithUncommonTypeTaxts
  - TypeTaxaAssignedToMoreThanOneTaxon
  - TypeTaxaWithIssues
