# coding: UTF-8
<<<<<<< HEAD
class Bolton::Catalog::Subfamily::Importer < Bolton::Catalog::Importer
||||||| merged common ancestors
class Bolton::Catalog::Subfamily::Importer < Bolton::Catalog::Importer
  private
=======
class Importers::Bolton::Catalog::Subfamily::Importer < Importers::Bolton::Catalog::Importer
  private
>>>>>>> master

  def parse_genus attributes = {}, options = {}
    parsing_synonym = attributes[:synonym_of]
    options = options.reverse_merge :header => :genus_header
    return unless @type == options[:header]
    Progress.method

<<<<<<< HEAD
    unless parsing_synonym
      name = @parse_result[:genus_name] || @parse_result[:name]
      parse_next_line
    end
||||||| merged common ancestors
    name = @parse_result[:name]
    status = @parse_result[:status]
    fossil = @parse_result[:fossil]
=======
    name = @parse_result[:name]
    status = @parse_result[:status]
    fossil = @parse_result[:fossil] || false
>>>>>>> master

    headline = consume :genus_headline
    name ||= headline[:protonym][:genus_name]
    fossil ||= headline[:protonym][:fossil]

    history = parse_taxonomic_history

    genus = Genus.import(
      :name => name,
      :fossil => fossil,
      :protonym => headline[:protonym],
      :note => headline[:note].try(:[], :text),
      :type_species => headline[:type_species],
      :taxonomic_history => history,
      :attributes => attributes
    )
    info_message = "Created #{genus.name}"
    info_message << " synonym of #{parsing_synonym.name}" if parsing_synonym
    Progress.info info_message

    parse_subgenera genus: genus
    parse_synonyms_of_genus genus
    parse_homonym_replaced_by_genus genus
    parse_genus_references genus

    genus
  end

  def parse_genus_references genus
    case @type
    when :genus_references_header
      parsed_genus_name = @parse_result[:genus_name]
      return if parsed_genus_name.present? && parsed_genus_name != genus.name
    when :genus_references_see_under
    else
      return
    end
    Progress.method

    title_only = @type == :genus_references_see_under
    references_only = false

    loop do
      texts = Bolton::Catalog::Grammar.parse(@line, root: :text).value
      title = Bolton::Catalog::TextToTaxt.convert texts[:text]

      references = nil
      unless title_only || references_only
        parse_next_line
        references = Bolton::Catalog::TextToTaxt.convert @parse_result[:texts]
      end

<<<<<<< HEAD
      if references_only
        references = title
        title = ''
      end
||||||| merged common ancestors
    parse_next_line
    expect :genus_line

    name = @parse_result[:name]
    fossil = @parse_result[:fossil]
    taxonomic_history = @paragraph
    taxonomic_history << parse_taxonomic_history
    genus = ::Genus.create! :name => name, :fossil => fossil, :status => 'homonym', :homonym_replaced_by => genus,
                          :subfamily => genus.subfamily, :tribe => genus.tribe, :taxonomic_history => clean_taxonomic_history(taxonomic_history)
  end
=======
    parse_next_line
    expect :genus_line

    name = @parse_result[:name]
    fossil = @parse_result[:fossil] || false
    taxonomic_history = @paragraph
    taxonomic_history << parse_taxonomic_history
    genus = ::Genus.create! :name => name, :fossil => fossil, :status => 'homonym', :homonym_replaced_by => genus,
                          :subfamily => genus.subfamily, :tribe => genus.tribe, :taxonomic_history => clean_taxonomic_history(taxonomic_history)
  end
>>>>>>> master

      genus.reference_sections.create! title: title, references: references
      
      parse_next_line

      break unless @type == :texts

      references_only = true
    end

  end

<<<<<<< HEAD
  ################################################
  def parse_homonym_replaced_by_genus replaced_by_genus
    parse_genus({
      status: 'homonym', homonym_replaced_by: replaced_by_genus,
      subfamily: replaced_by_genus.subfamily, tribe: replaced_by_genus.tribe},
      header: :homonym_replaced_by_genus_header)
||||||| merged common ancestors
  def parse_junior_synonym_of_genus genus
    parsed_text = ''
    name = @parse_result[:name]
    fossil = @parse_result[:fossil]
    taxonomic_history = @paragraph
    taxonomic_history << parse_taxonomic_history
    genus = ::Genus.create! :name => name, :fossil => fossil, :status => 'synonym', :synonym_of => genus,
                          :subfamily => genus.subfamily, :tribe => genus.tribe, :taxonomic_history => clean_taxonomic_history(taxonomic_history)
    parsed_text << taxonomic_history
    parsed_text << parse_homonym_replaced_by_genus_synonym
=======
  def parse_junior_synonym_of_genus genus
    parsed_text = ''
    name = @parse_result[:name]
    fossil = @parse_result[:fossil] || false
    taxonomic_history = @paragraph
    taxonomic_history << parse_taxonomic_history
    genus = ::Genus.create! :name => name, :fossil => fossil, :status => 'synonym', :synonym_of => genus,
                          :subfamily => genus.subfamily, :tribe => genus.tribe, :taxonomic_history => clean_taxonomic_history(taxonomic_history)
    parsed_text << taxonomic_history
    parsed_text << parse_homonym_replaced_by_genus_synonym
>>>>>>> master
  end

  ################################################
  def parse_synonyms_of_genus genus
    return unless @type == :junior_synonyms_of_genus_header
    Progress.method

    parse_next_line
    attributes = {synonym_of: genus, status: 'synonym', subfamily: genus.subfamily, tribe: genus.tribe}

    while parse_genus attributes, header: :genus_headline; end
  end

<<<<<<< HEAD
  ################################################
  def parse_genera_lists
    parse_next_line while @type == :genera_list
||||||| merged common ancestors
  def parse_genera_lists parent_rank, parent_attributes = {}
    return '' unless @type == :genera_list
    Progress.info 'parse_genera_lists'

    parsed_text = ''

    while @type == :genera_list
      parsed_text << @paragraph
      @parse_result[:genera].each do |genus|
        attributes = {:name => genus[:name], :fossil => genus[:fossil], :status => genus[:status] || 'valid'}.merge parent_attributes
        attributes.merge!(:incertae_sedis_in => parent_rank.to_s) if @parse_result[:incertae_sedis]

        name = genus[:name]
        genus = ::Genus.find_by_name name
        if genus
          # Several genera are listed both as incertae sedis in subfamily, and as a genus of an incertae sedis tribe
          if ['Zherichinius', 'Miomyrmex'].include? name
            genus.update_attributes attributes
          else
            raise "Genus #{name} found in more than one list"
          end
        else
          ::Genus.create! attributes
        end
      end

      parse_next_line
    end

    parsed_text
=======
  def parse_genera_lists parent_rank, parent_attributes = {}
    return '' unless @type == :genera_list
    Progress.info 'parse_genera_lists'

    parsed_text = ''

    while @type == :genera_list
      parsed_text << @paragraph
      @parse_result[:genera].each do |genus|
        attributes = {:name => genus[:name], :fossil => genus[:fossil] || false, :status => genus[:status] || 'valid'}.merge parent_attributes
        attributes.merge!(:incertae_sedis_in => parent_rank.to_s) if @parse_result[:incertae_sedis]

        name = genus[:name]
        genus = ::Genus.find_by_name name
        if genus
          # Several genera are listed both as incertae sedis in subfamily, and as a genus of an incertae sedis tribe
          if ['Zherichinius', 'Miomyrmex'].include? name
            genus.update_attributes attributes
          else
            raise "Genus #{name} found in more than one list"
          end
        else
          ::Genus.create! attributes
        end
      end

      parse_next_line
    end

    parsed_text
>>>>>>> master
  end

  #################################################################
  # parse a subfamily or tribe's genera
  def parse_genera attributes = {}
    return unless @type == :genera_header || @type == :genus_header
    Progress.method

    parse_next_line if @type == :genera_header
    parse_genus attributes while @type == :genus_header
  end

  def parse_genera_incertae_sedis rank, attributes = {}, expected_header = :genera_incertae_sedis_header
    return unless @type == expected_header
    Progress.method

    parse_next_line
    parse_genus attributes.reverse_merge(incertae_sedis_in: rank) while @type == :genus_header
  end

end
