class AuthorityList::Exporter
  def initialize show_progress = false
    Progress.init show_progress
  end

  def export directory
    File.open("#{directory}/antcat_authority_list.txt", 'w') do |file|
      write_header file
      for taxon in Taxon.all
        row = format_taxon taxon
        write file, row if row
      end
    end
    Progress.show_results
  end

  def write_header file
    write file, format('subfamily', 'tribe', 'genus', 'species', 'subspecies', 'status', 'fossil')
  end

  def write file, line
    file.puts line
  end

  def format *values
    values.join "\t"
  end

  def format_taxon taxon
    Progress.tally_and_show_progress 1000

    case taxon
    when Species
      return unless taxon.genus && taxon.genus.tribe && taxon.genus.tribe.subfamily
      format taxon.subfamily.name, taxon.genus.tribe.name, taxon.genus.name, taxon.name, taxon.status, taxon.fossil? ? 'true' : ''

    when Subspecies
      return unless taxon.species && taxon.species.genus && taxon.species.genus.tribe && taxon.species.genus.tribe.subfamily
      format taxon.species.genus.subfamily.name, taxon.species.genus.tribe.name, taxon.species.genus.name,
                  taxon.species.name, taxon.name, taxon.status, taxon.fossil? ? 'true' : ''
    else nil
    end
  end

  #private
  #def boolean_to_antweb boolean
    #case boolean
    #when true: 'TRUE'
    #when false: 'FALSE'
    #when nil: nil
    #else raise
    #end
  #end

  #def convert_to_antweb_array values
    #[values[:subfamily], values[:tribe], values[:genus], values[:species], nil, nil, boolean_to_antweb(values[:valid?]), boolean_to_antweb(values[:available?]), values[:current_valid_name], nil, values[:taxonomic_history], boolean_to_antweb(values[:fossil?])]
  #end

end
