# coding: UTF-8
class Exporters::Antweb::Exporter
  def initialize show_progress = false
    Progress.init show_progress, Taxon.count
  end

  def export directory
    File.open("#{directory}/bolton.txt", 'w') do |file|
      file.puts header
      get_taxa.each do |taxon|
        row = export_taxon taxon
        file.puts row.join("\t") if row
      end
    end
    Progress.show_results
  end

  def get_taxa
    Taxon.joins protonym: [{authorship: :reference}]
  end

  def export_taxon taxon
    Progress.tally_and_show_progress 100

    attributes = {
      antcat_id:            taxon.id,
      status:               taxon.status,
      available?:           !taxon.invalid?,
      fossil?:              taxon.fossil,
      history:              Exporters::Antweb::Formatter.new(taxon).format,
      author_date:          taxon.authorship_string,
      author_date_html:     taxon.authorship_html_string,
      current_valid_name:   (taxon.current_valid_taxon ? taxon.current_valid_taxon.name.name : taxon.name.name),
      original_combination?:taxon.original_combination?,
      original_combination: taxon.original_combination.try(:name).try(:name),
      authors:              taxon.author_last_names_string,
      year:                 taxon.year && taxon.year.to_s,

    }

    case taxon
    when Family
      convert_to_antweb_array attributes.merge subfamily: 'Formicidae'
    when Subfamily
      convert_to_antweb_array attributes.merge subfamily: taxon.name.to_s
    when Tribe
      convert_to_antweb_array attributes.merge subfamily: taxon.subfamily.name.to_s, tribe: taxon.name.to_s
    when Genus
      subfamily_name = taxon.subfamily && taxon.subfamily.name.to_s || 'incertae_sedis'
      tribe_name = taxon.tribe && taxon.tribe.name.to_s
      convert_to_antweb_array attributes.merge subfamily: subfamily_name, tribe: tribe_name, genus: taxon.name.to_s
    when Subgenus
      subfamily_name = taxon.subfamily && taxon.subfamily.name.to_s || 'incertae_sedis'
      genus_name = taxon.genus && taxon.genus.name.to_s
      convert_to_antweb_array attributes.merge subfamily: subfamily_name, genus: genus_name, subgenus: taxon.name.epithet.gsub(/[\(\)]/,'')
    when Species
      return unless taxon.genus
      subfamily_name = taxon.genus.subfamily && taxon.genus.subfamily.name.to_s || 'incertae_sedis'
      tribe_name = taxon.genus.tribe && taxon.genus.tribe.name.to_s
      convert_to_antweb_array attributes.merge subfamily: subfamily_name, tribe: tribe_name, genus: taxon.genus.name.to_s, species: taxon.name.epithet
    when Subspecies
      subfamily_name = taxon.genus.subfamily && taxon.genus.subfamily.name.to_s || 'incertae_sedis'
      tribe_name = taxon.genus.tribe && taxon.genus.tribe.name.to_s
      convert_to_antweb_array attributes.merge subfamily: subfamily_name, tribe: tribe_name, genus: taxon.genus.name.to_s, species: taxon.name.epithets
    else nil
    end

  end

  def boolean_to_antweb boolean
    case boolean
    when true then 'TRUE'
    when false then 'FALSE'
    when nil then nil
    else raise
    end
  end

  def header
    "antcat id\t"               +# [0]
    "subfamily\t"               +# [1]
    "tribe\t"                   +# [2]
    "genus\t"                   +# [3]
    "subgenus\t"                +# [4]
    "species\t"                 +# [5]
    "author date\t"             +# [6]
    "author date html\t"        +# [7]
    "authors\t"                 +# [8]
    "year\t"                    +# [9]
    "status\t"                  +# [10]
    "available\t"               +# [11]
    "current valid name\t"      +# [12]
    "original combination\t"    +# [13]
    "was original combination\t"+# [14]
    "fossil\t"                  +# [15]
    "taxonomic history html"     # [16]
  end

  def convert_to_antweb_array values
    [values[:antcat_id],
     values[:subfamily],
     values[:tribe],
     values[:genus],
     values[:subgenus],
     values[:species],
     values[:author_date],
     values[:author_date_html],
     values[:authors],
     values[:year],
     values[:status],
     boolean_to_antweb(values[:available?]),
     values[:current_valid_name],
     boolean_to_antweb(values[:original_combination?]),
     values[:original_combination],
     boolean_to_antweb(values[:fossil?]),
     values[:history]]
  end

end
