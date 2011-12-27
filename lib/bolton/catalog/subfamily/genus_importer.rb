# coding: UTF-8
class Bolton::Catalog::Subfamily::Importer < Bolton::Catalog::Importer

  def parse_genus attributes = {}, options = {}
    options = options.reverse_merge :expect_genus_headline => true, :header => :genus_header
    return unless @type == options[:header]
    Progress.method

    name = @parse_result[:name]
    status = 'valid'
    fossil = @parse_result[:fossil]

    parse_next_line
    expect :genus_headline if options[:expect_genus_headline]

    taxonomic_history = @paragraph
    parse_next_line
    taxonomic_history << parse_genus_taxonomic_history if @line

    genus = ::Genus.create!({:name => name, :fossil => fossil, :status => status, :taxonomic_history => clean_taxonomic_history(taxonomic_history)}.merge(attributes))
    Progress.info "Created #{genus.name}"

    #parse_homonym_replaced_by_genus(genus)
    #taxonomic_history << parse_junior_synonyms_of_genus(genus)
    #taxonomic_history << parse_subgenera(genus)
    #taxonomic_history << parse_genus_references

    genus.reload.update_attributes :taxonomic_history => clean_taxonomic_history(taxonomic_history)
  end

  def parse_genus_taxonomic_history
    Progress.method
    taxonomic_history, @parsed_taxonomic_history = parse_taxonomic_history :genus_taxonomic_history_item
    taxonomic_history
  end

  def parsed_taxonomic_history
    @parsed_taxonomic_history
  end

  def parse_genus_references
    return '' unless @type == :genus_references_header || @type == :genus_references_see_under

    Progress.method
    parsed_text = @paragraph
    parse_reference_section = @type != :genus_references_see_under
    parse_next_line
    parsed_text << @paragraph
    texts = []
    if @type == :anything
      texts.concat @parse_result[:texts] if @parse_result[:texts]
      @parse_result[:texts] = texts
      @parse_result[:type] = :reference_section
      @type = :reference_section
      Progress.info 'reparsed as reference_section'
    end
    return parsed_text unless parse_reference_section && @type == :reference_section
    parse_next_line
    if @type == :anything
      texts.concat @parse_result[:texts] if @parse_result[:texts]
      @parse_result[:texts] = texts
      @parse_result[:type] = :reference_section
      @type = :reference_section
      Progress.info 'reparsed as reference_section'
      parsed_text << @paragraph
      parse_next_line
    end
    parsed_text
  end

  #def parse_homonym_replaced_by_genus genus
    #return '' unless @type == :homonym_replaced_by_genus_header
    #Progress.method

    #taxonomic_history = @paragraph
    #parse_next_line
    #expect :genus_headline

    #name = @parse_result[:genus_name]
    #fossil = @parse_result[:fossil]
    #local_taxonomic_history = @paragraph
    #taxonomic_history << local_taxonomic_history
    #parse_next_line
    #taxonomic_history << parse_genus_taxonomic_history
    #local_taxonomic_history << local_taxonomic_history
    #genus = ::Genus.create! :name => name, :fossil => fossil, :status => 'homonym', :homonym_replaced_by => genus,
                          #:subfamily => genus.subfamily, :tribe => genus.tribe, :taxonomic_history => clean_taxonomic_history(local_taxonomic_history)
    #taxonomic_history
  #end

  #def parse_junior_synonyms_of_genus genus
    #return '' unless @type == :junior_synonyms_of_genus_header
    #Progress.method

    #parsed_text = @paragraph
    #parse_next_line

    #parsed_text << parse_junior_synonym_of_genus(genus) while @type == :genus_headline

    #parsed_text
  #end

  #def parse_junior_synonym_of_genus genus
    #Progress.method
    #parsed_text = ''
    #name = @parse_result[:genus_name]
    #fossil = @parse_result[:fossil]
    #taxonomic_history = @paragraph
    #parse_next_line
    #taxonomic_history << parse_genus_taxonomic_history
    #genus = ::Genus.create! :name => name, :fossil => fossil, :status => 'synonym', :synonym_of => genus,
                          #:subfamily => genus.subfamily, :tribe => genus.tribe, :taxonomic_history => clean_taxonomic_history(taxonomic_history)
    #Progress.info "Created #{genus.name} junior synonym of genus"
    #parsed_text << taxonomic_history
    #parsed_text << parse_homonym_replaced_by_genus(genus)
#  end

  def parse_genera_lists parent_rank, parent_attributes = {}
    return '' unless @type == :genera_list
    Progress.method

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
  end

  #################################################################
  # parse a subfamily or tribe's genera
  def parse_genera
    return unless @type == :genera_header || @type == :genus_header
    Progress.method

    parse_next_line if @type == :genera_header
    parse_genus while @type == :genus_header
  end

  def parse_genera_of_hong
    return unless @type == :genera_of_hong_header
    Progress.method

    parse_next_line
    parse_genus while @type == :genus_header
  end

  def parse_genera_incertae_sedis expected_header = :genera_incertae_sedis_header
    return unless @type == expected_header
    Progress.method

    parse_next_line
    parse_genus while @type == :genus_header
  end

end
