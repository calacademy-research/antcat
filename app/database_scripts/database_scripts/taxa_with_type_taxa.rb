module DatabaseScripts
  class TaxaWithTypeTaxa < DatabaseScript
    def results
      Taxon.where.not(type_taxon_id: nil)
    end

    def render
      as_table do |t|
        t.header :taxon, :status,
          :type_taxon, :type_taxt, :tt_status,
          :tt_expansion,
          :type_taxon_now, :ttn_status,
          :tt_different_from_ttn?, :cvt_of_tt_if_different_from_ttn
        t.rows do |taxon|
          type_taxon = taxon.type_taxon
          type_taxon_now = type_taxon.now
          cvt_of_type_taxon = type_taxon.current_valid_taxon

          [
            markdown_taxon_link(taxon),
            taxon.status,

            markdown_taxon_link(type_taxon),
            format_type_taxt(taxon.type_taxt),
            type_taxon.status,

            type_taxon_expansion(taxon.type_taxt, type_taxon),

            markdown_taxon_link(type_taxon_now),
            type_taxon_now.status,

            ('Yes' if type_taxon != type_taxon_now),
            (cvt_of_type_taxon.link_to_taxon + ' (' + cvt_of_type_taxon.status + ')' if cvt_of_type_taxon && type_taxon_now != cvt_of_type_taxon)
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

      def type_taxon_expansion _type_taxt, type_taxon
        string = ''

        case type_taxon.status
        when Status::VALID
          string << '[no expansion]'
        when Status::SYNONYM
          string << ' (junior synonym of '
          string << type_taxon.current_valid_taxon.link_to_taxon
          string << ')'
        else
          string << '??'
        end

        string
      end
  end
end

__END__

category: Catalog
tags: [list, new!, slow]

description: >
  This script was added to investigate automatic "now links" for type taxa.


  `type_taxon.now` is a new experimental function for resolving taxa.


  Ignore "TT expansion", it's very WIP.


  "CVT of TT if different from TTN" = `current_valid_taxon` of `type_taxon` if different from `type_taxon.now`


  Common `type_taxt`s ("by monotypy", "by original designation" and "by subsequent designation of ...") are abbreviated.

related_scripts:
  - TaxaWithTypeTaxa
  - TaxaWithTypeTaxt
  - TypeTaxaAssignedToMoreThanOneTaxon
  - TypeTaxaWithIssues
