class Exporters::Antweb::ExportTaxon
  include ActionView::Helpers::TagHelper # For `#content_tag`.
  include ActionView::Context # For `#content_tag`.

  HEADER =
    "antcat id\t"                + #  [0]
    "subfamily\t"                + #  [1]
    "tribe\t"                    + #  [2]
    "genus\t"                    + #  [3]
    "subgenus\t"                 + #  [4]
    "species\t"                  + #  [5]
    "subspecies\t"               + #  [6]
    "author date\t"              + #  [7]
    "author date html\t"         + #  [8]
    "authors\t"                  + #  [9]
    "year\t"                     + # [10]
    "status\t"                   + # [11]
    "available\t"                + # [12]
    "current valid name\t"       + # [13]
    "original combination\t"     + # [14]
    "was original combination\t" + # [15]
    "fossil\t"                   + # [16]
    "taxonomic history html\t"   + # [17]
    "reference id\t"             + # [18]
    "bioregion\t"                + # [19]
    "country\t"                  + # [20]
    "current valid rank\t"       + # [21]
    "hol id\t"                   + # [22]
    "current valid parent"         # [23]

  def call taxon
    export_taxon taxon
  end

  private

    def export_taxon taxon
      authorship_reference = taxon.authorship_reference
      parent = taxon.parent && (taxon.parent.current_valid_taxon || taxon.parent)

      attributes = {
        antcat_id:              taxon.id,
        status:                 taxon.status,
        available?:             !taxon.invalid?,
        fossil?:                taxon.fossil,
        history:                export_history(taxon),
        author_date:            taxon.author_citation,
        author_date_html:       authorship_html_string(taxon),
        original_combination?:  taxon.original_combination?,
        original_combination:   original_combination(taxon)&.name&.name,
        authors:                authorship_reference.authors_for_keey,
        year:                   authorship_reference.year_or_no_year,
        reference_id:           authorship_reference.is_a?(MissingReference) ? nil : authorship_reference.id,
        biogeographic_region:   taxon.biogeographic_region,
        locality:               taxon.protonym.locality,
        rank:                   taxon.class.to_s,
        hol_id:                 taxon.hol_id,
        parent:                 parent&.name&.name || 'Formicidae'
      }

      attributes[:current_valid_name] =
        if taxon.current_valid_taxon_including_synonyms
          taxon.current_valid_taxon_including_synonyms.name.name
        end

      convert_to_antweb_array attributes.merge(Exporters::Antweb::AntwebAttributes[taxon])
    end

    def boolean_to_antweb boolean
      case boolean
      when true  then 'TRUE'
      when false then 'FALSE'
      when nil   then nil
      else            raise
      end
    end

    def convert_to_antweb_array values
      [
        values[:antcat_id],
        values[:subfamily],
        values[:tribe],
        values[:genus],
        values[:subgenus],
        values[:species],
        values[:subspecies],
        values[:author_date],
        values[:author_date_html],
        values[:authors],
        values[:year],
        values[:status],
        boolean_to_antweb(values[:available?]),
        add_subfamily_to_current_valid(values[:subfamily], values[:current_valid_name]),
        boolean_to_antweb(values[:original_combination?]),
        values[:original_combination],
        boolean_to_antweb(values[:fossil?]),
        values[:history],
        values[:reference_id],
        values[:biogeographic_region],
        values[:locality],
        values[:rank],
        values[:hol_id],
        values[:parent]
      ]
    end

    def add_subfamily_to_current_valid subfamily, current_valid_name
      return unless current_valid_name
      "#{subfamily} #{current_valid_name}"
    end

    def authorship_html_string taxon
      reference = taxon.authorship_reference

      plain_text = reference.decorate.plain_text
      content_tag :span, reference.keey, title: plain_text
    end

    def original_combination taxon
      taxon.class.where(status: Status::ORIGINAL_COMBINATION, current_valid_taxon: taxon).first
    end

    def export_history taxon
      taxon = taxon.decorate

      content_tag :div, class: 'antcat_taxon' do # NOTE `.antcat_taxon` is used on AntWeb.
        content = ''.html_safe
        content << taxon.statistics(include_invalid: false)
        content << genus_species_header_notes_taxt(taxon)
        content << Exporters::Antweb::ExportHeadline[taxon]
        content << Exporters::Antweb::ExportHistoryItems[taxon]
        content << taxon.child_lists(for_antweb: true)
        content << Exporters::Antweb::ExportReferenceSections[taxon]
      end
    end

    def genus_species_header_notes_taxt taxon
      return if taxon.genus_species_header_notes_taxt.blank?
      content_tag :div, TaxtPresenter[taxon.genus_species_header_notes_taxt].to_antweb
    end
end
