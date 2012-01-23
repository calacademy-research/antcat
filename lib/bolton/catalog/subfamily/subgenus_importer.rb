# coding: UTF-8
class Bolton::Catalog::Subfamily::Importer < Bolton::Catalog::Importer
  private

  def parse_subgenera genus
    return '' unless @type == :subgenera_header
    Progress.method

    parsed_text = @paragraph
    parse_next_line

    if @type == :texts
      parse_next_line
    end

    expect :subgenus_header
    parsed_text << parse_subgenus(genus) while @type == :subgenus_header

    parsed_text
  end

  def parse_subgenus genus
    return unless @type == :subgenus_header
    Progress.method

    name = @parse_result[:name]
    parsed_text = @paragraph

    parse_next_line
    expect :genus_headline

    taxonomic_history = @paragraph
    parse_next_line
    taxonomic_history << parse_taxonomic_history

    raise "Subgenus #{name} already exists" if Subgenus.find_by_name name
    subgenus = Subgenus.create! :name => name, :status => 'valid', :genus => genus, :taxonomic_history => clean_taxonomic_history(taxonomic_history)
    Progress.info "Created #{subgenus.name}"

    taxonomic_history << parse_homonym_replaced_by_subgenus
    taxonomic_history << parse_junior_synonyms_of_subgenus(subgenus)
    parsed_text << taxonomic_history

    subgenus.reload.update_attributes :taxonomic_history => clean_taxonomic_history(taxonomic_history)

    parsed_text
  end

  def parse_homonym_replaced_by_subgenus
    return '' unless @type == :homonym_replaced_by_genus_header
    Progress.method

    parsed_text = @paragraph
    parse_next_line

    parsed_text << @paragraph
    parse_next_line

    parsed_text << @paragraph << parse_taxonomic_history

    parsed_text
  end

  def parse_junior_synonyms_of_subgenus subgenus
    return '' unless @type == :junior_synonyms_of_subgenus_header
    Progress.method

    parsed_text = @paragraph
    parse_next_line

    parsed_text << parse_junior_synonym_of_subgenus(subgenus) while @type == :genus_headline

    parsed_text
  end

  def parse_junior_synonym_of_subgenus subgenus
    Progress.method
    parsed_text = ''
    name = @parse_result[:genus_name]
    fossil = @parse_result[:fossil]
    taxonomic_history = @paragraph
    parse_next_line
    taxonomic_history << parse_taxonomic_history
    subgenus = Subgenus.create! :name => name, :fossil => fossil, :status => 'synonym', :synonym_of => subgenus,
                             :genus => subgenus.genus, :taxonomic_history => clean_taxonomic_history(taxonomic_history)
    Progress.info "Created #{subgenus.name} junior synonym of subgenus"
    parsed_text << taxonomic_history
  end


end
