# coding: UTF-8
class Exporters::Antweb::Exporter
  def initialize show_progress = false
    Progress.init show_progress, Taxon.count
  end

  def export directory
    File.open("#{directory}/bolton.txt", 'w') do |file|
      file.puts "subfamily\ttribe\tgenus\tspecies\tauthor date\tcountry\tstatus\tavailable\tcurrent valid name\toriginal combination\tfossil\ttaxonomic history"
      Taxon.all.each do |taxon|
        row = export_taxon taxon
        file.puts row.join("\t") if row
      end
    end
    Progress.show_results
  end

  def export_taxon taxon
    Progress.tally_and_show_progress 100

    return unless self.class.exportable? taxon

    attributes = {
      status:       taxon.status,
      available?:   !taxon.invalid?,
      fossil?:      taxon.fossil,
      history:      Exporters::Antweb::Formatter.new(taxon).format,
      author_date:  taxon.authorship_string,
      current_valid_name:
                    (taxon.current_valid_taxon ? taxon.current_valid_taxon.name.name : taxon.name.name),
    }

    case taxon
    when Family
      convert_to_antweb_array attributes.merge subfamily: 'Formicidae'
    when Subfamily
      convert_to_antweb_array attributes.merge subfamily: taxon.name.to_s
    when Genus
      subfamily_name = taxon.subfamily && taxon.subfamily.name.to_s || 'incertae_sedis'
      tribe_name = taxon.tribe && taxon.tribe.name.to_s
      convert_to_antweb_array attributes.merge subfamily: subfamily_name, tribe: tribe_name, genus: taxon.name.to_s
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

  def self.exportable? taxon
    not (taxon.kind_of?(Subgenus) || taxon.kind_of?(Tribe))
  end

  private
  def boolean_to_antweb boolean
    case boolean
    when true then 'TRUE'
    when false then 'FALSE'
    when nil then nil
    else raise
    end
  end

  def convert_to_antweb_array values
    [values[:subfamily],
     values[:tribe],
     values[:genus],
     values[:species],
     values[:author_date],
     nil,
     values[:status],
     boolean_to_antweb(values[:available?]),
     values[:current_valid_name],
     nil,
     boolean_to_antweb(values[:fossil?]),
     values[:history]]
  end

end
