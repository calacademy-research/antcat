# Export via `rake antweb:export`.
# This class will grow for some more time while decoupling the export
# code from the rest of the code.
#
# TODO remove most CSS throughout `Exporters::Antweb`.

include ActionView::Helpers::TagHelper # For `#content_tag`.
include ActionView::Context # For `#content_tag`.
include Exporters::Antweb::MonkeyPatchTaxon

class Exporters::Antweb::Exporter
  def self.antcat_taxon_link taxon, label = "AntCat"
    url = "http://www.antcat.org/catalog/#{taxon.id}"
    %Q[<a class="link_to_external_site" href="#{url}">#{label}</a>].html_safe
  end

  def self.antcat_taxon_link_with_name taxon
    antcat_taxon_link taxon, taxon.name_with_fossil
  end

  def initialize show_progress = false
    Progress.init show_progress, Taxon.count
  end

  def export directory
    File.open("#{directory}/antcat.antweb.txt", 'w') do |file|
      file.puts header

      taxa_ids.each_slice(1000) do |chunk|
        Taxon.where(id: chunk)
          .order("field(taxa.id, #{chunk.join(',')})")
          .joins(protonym: [{authorship: :reference}])
          .includes(protonym: [{authorship: :reference}])
          .each do |taxon|
          begin
            if !taxon.name.nonconforming_name and !taxon.name_cache.index('?')
              row = export_taxon taxon
              if row
                row[20].delete!('\"') if row[20]
                row.each do |col|
                  if col.is_a? String
                    col.delete!("\n")
                    col.delete!("\r")
                  end
                end
              end
              file.puts row.join("\t") if row
            end
          rescue Exception => e
            puts "Fatal error exporting taxon id: #{taxon.id}"
            puts e.message
            puts e.backtrace.inspect
          end
        end
      end
      Progress.show_results
    end
  end

  private
    def taxa_ids
      Taxon.joins(protonym: [{ authorship: :reference }])
        .order(:status).pluck(:id).reverse
    end

    def export_taxon taxon
      puts "Processing: #{taxon.id}" if ENV['DEBUG']
      Progress.tally_and_show_progress 100

      reference = taxon.protonym.authorship.reference
      reference_id = reference.kind_of?(MissingReference) ? nil : reference.id

      parent_taxon = taxon.parent && (taxon.parent.current_valid_taxon ? taxon.parent.current_valid_taxon : taxon.parent)
      parent_name = parent_taxon.try(:name).try(:name)
      parent_name ||= 'Formicidae'

      attributes = {
        antcat_id:              taxon.id,
        status:                 taxon.status,
        available?:             !taxon.invalid?,
        fossil?:                taxon.fossil,
        history:                export_history(taxon),
        author_date:            taxon.author_citation,
        author_date_html:       authorship_html_string(taxon),
        original_combination?:  taxon.original_combination?,
        original_combination:   original_combination(taxon).try(:name).try(:name),
        authors:                author_last_names_string(taxon),
        year:                   year(taxon) && year(taxon).to_s,
        reference_id:           reference_id,
        biogeographic_region:   taxon.biogeographic_region,
        locality:               taxon.protonym.locality,
        rank:                   taxon.class.to_s,
        hol_id:                 taxon.hol_id,
        parent:                 parent_name,
      }

      attributes[:current_valid_name] =
        if taxon.current_valid_taxon_including_synonyms
          taxon.current_valid_taxon_including_synonyms.name.to_s
        else
          nil
        end

      begin
        convert_to_antweb_array taxon.add_antweb_attributes(attributes)
      rescue Exception => exception
        STDERR.puts "========================#{taxon.id}================================"
        STDERR.puts "An error of type #{exception} happened, message is #{exception.message}"
        STDERR.puts exception.backtrace
        STDERR.puts "========================================================"
      end
    end

    def boolean_to_antweb boolean
      case boolean
      when true  then 'TRUE'
      when false then 'FALSE'
      when nil   then nil
      else            raise
      end
    end

    def header
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
        values[:parent],
      ]
    end

    def add_subfamily_to_current_valid subfamily, current_valid_name
      return unless current_valid_name
      "#{subfamily} #{current_valid_name}"
    end

    # TODO rename.
    def author_last_names_string taxon
      reference = taxon.authorship_reference
      return unless reference

      reference.authors_for_keey
    end

    def authorship_html_string taxon
      reference = taxon.authorship_reference
      return unless reference

      formatted = reference.decorate.formatted
      content_tag :span, reference.keey, title: formatted
    end

    # TODO rename.
    def year taxon
      reference = taxon.authorship_reference
      return unless reference

      reference.year_or_no_year
    end

    # The original_combination accessor returns the taxon with 'original combination'
    # status whose 'current valid taxon' points to us.
    def original_combination taxon
      taxon.class.where(status: 'original combination', current_valid_taxon_id: taxon.id).first
    end

    def export_history taxon
      taxon = taxon.decorate
      content_tag :div, class: 'antcat_taxon' do
        content = ''.html_safe
        content << taxon.statistics(include_invalid: false)
        content << genus_species_header_notes_taxt(taxon)
        content << taxon.headline(for_antweb: true)
        content << export_history_items(taxon)
        content << taxon.child_lists(for_antweb: true)
        content << export_reference_sections(taxon)
      end
    end

    def export_history_items taxon
      Exporters::Antweb::ExportHistoryItems[taxon]
    end

    def export_reference_sections taxon
      Exporters::Antweb::ExportReferenceSections[taxon]
    end

    def genus_species_header_notes_taxt taxon
      return unless taxon.genus_species_header_notes_taxt.present?
      content_tag :div,
        TaxtPresenter[taxon.genus_species_header_notes_taxt].to_antweb,
        class: 'genus_species_header_notes_taxt'
    end
end
