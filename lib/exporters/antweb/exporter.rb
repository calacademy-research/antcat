# coding: UTF-8
class Exporters::Antweb::Exporter
  def initialize show_progress = false
    Progress.init show_progress, Taxon.count
  end

  def export directory
    File.open("#{directory}/antcat.antweb.txt", 'w') do |file|
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

    reference = taxon.protonym.authorship.reference
    reference_id = reference.kind_of?(MissingReference) ? nil : reference.id

    parent_taxon = taxon.parent && (taxon.parent.current_valid_taxon ? taxon.parent.current_valid_taxon : taxon.parent)
    parent_name = parent_taxon.try(:name).try(:name)
    parent_name ||= 'Formicidae'

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
      reference_id:         reference_id,
      biogeographic_region: taxon.biogeographic_region,
      locality:             taxon.protonym.locality,
      rank:                 taxon.class.to_s,
      parent:               parent_name,
    }

    convert_to_antweb_array taxon.add_antweb_attributes(attributes)

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
    "subspecies\t"              +# [6]
    "author date\t"             +# [7]
    "author date html\t"        +# [8]
    "authors\t"                 +# [9]
    "year\t"                    +# [10]
    "status\t"                  +# [11]
    "available\t"               +# [12]
    "current valid name\t"      +# [13]
    "original combination\t"    +# [14]
    "was original combination\t"+# [15]
    "fossil\t"                  +# [16]
    "taxonomic history html\t"  +# [17]
    "reference id\t"            +# [18]
    "bioregion\t"               +# [19]
    "country\t"                 +# [20]
    "current valid rank\t"      +# [21]
    "current valid parent"       # [22]
  end

  def convert_to_antweb_array values
    [values[:antcat_id],
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
     values[:current_valid_name],
     boolean_to_antweb(values[:original_combination?]),
     values[:original_combination],
     boolean_to_antweb(values[:fossil?]),
     values[:history],
     values[:reference_id],
     values[:biogeographic_region],
     values[:locality],
     values[:rank],
     values[:parent],
    ]
  end

end
