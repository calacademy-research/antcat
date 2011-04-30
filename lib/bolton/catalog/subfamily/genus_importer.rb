class Bolton::Catalog::Subfamily::Importer < Bolton::Catalog::Importer
  private

  def parse_genus attributes = {}, expect_genus_line = true
    return unless @type == :genus_header
    Progress.info 'parse_genus'

    name = @parse_result[:name]
    status = @parse_result[:status]
    fossil = @parse_result[:fossil]

    parse_next_line
    expect :genus_line if expect_genus_line

    taxonomic_history = @paragraph
    taxonomic_history << parse_taxonomic_history

    genus = Genus.find_by_name name
    if genus
      attributes = {:status => status, :taxonomic_history => taxonomic_history}.merge(attributes)
      check_status_change genus, attributes[:status]
      raise "Genus #{name} fossil change from #{genus.fossil?} to #{fossil}" if fossil != genus.fossil
      genus.update_attributes attributes
      Progress.info "Updated #{genus.name}"
    else
      check_existence name, genus
      genus = Genus.create!({:name => name, :fossil => fossil, :status => status, :taxonomic_history => clean_taxonomic_history(taxonomic_history)}.merge(attributes))
      Progress.info "Created #{genus.name}"
    end

    taxonomic_history << parse_homonym_replaced_by_genus
    taxonomic_history << parse_junior_synonyms_of_genus(genus)
    taxonomic_history << parse_subgenera(genus)
    taxonomic_history << parse_genus_references

    genus.reload.update_attributes :taxonomic_history => clean_taxonomic_history(taxonomic_history)
  end

  def parse_genus_references
    return '' unless @type == :genus_references_header
    Progress.info 'parse_genus_references'
    parsed_text = @paragraph
    parsed_text << parse_taxonomic_history
    parsed_text
  end

  def parse_homonym_replaced_by_genus
    return '' unless @type == :homonym_replaced_by_genus_header
    Progress.info 'parse_homonym_replaced_by_genus'

    parsed_text = @paragraph
    parse_next_line

    parsed_text << @paragraph << parse_taxonomic_history

    parsed_text
  end

  def parse_junior_synonyms_of_genus genus
    return '' unless @type == :junior_synonyms_of_genus_header
    Progress.info 'parse_junior_synonyms_of_genus'

    parsed_text = @paragraph
    parse_next_line

    parsed_text << parse_junior_synonym_of_genus(genus) while @type == :genus_line

    parsed_text
  end

  def parse_junior_synonym_of_genus genus
    parsed_text = ''
    name = @parse_result[:name]
    fossil = @parse_result[:fossil]
    taxonomic_history = @paragraph
    taxonomic_history << parse_taxonomic_history
    genus = Genus.create! :name => name, :fossil => fossil, :status => 'synonym', :synonym_of => genus,
                          :subfamily => genus.subfamily, :tribe => genus.tribe, :taxonomic_history => clean_taxonomic_history(taxonomic_history)
    parsed_text << taxonomic_history
    parsed_text << parse_homonym_replaced_by_genus_synonym
  end

  def parse_homonym_replaced_by_genus_synonym
    return '' unless @type == :homonym_replaced_by_genus_synonym_header
    Progress.info 'parse_homonym_replaced_by_genus_synonym'

    parsed_text = @paragraph
    parse_next_line

    parsed_text << @paragraph << parse_taxonomic_history

    parsed_text
  end

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
        genus = Genus.find_by_name name
        if genus
          # Several genera are listed both as incertae sedis in subfamily, and as a genus of an incertae sedis tribe
          if ['Zherichinius', 'Miomyrmex'].include? name
            genus.update_attributes attributes
          else
            raise "Genus #{name} found in more than one list"
          end
        else
          Genus.create! attributes
        end
      end

      parse_next_line
    end

    parsed_text
  end

  def parse_genera
    return unless @type == :genera_header || @type == :genus_header
    Progress.info 'parse_genera'

    parse_next_line if @type == :genera_header

    parse_genus while @type == :genus_header
  end

  def parse_genera_incertae_sedis
    return unless @type == :genera_incertae_sedis_header
    Progress.info 'parse_genera_incertae_sedis'

    parse_next_line
    parse_genus while @type == :genus_header
  end

  def check_status_change genus, status
    return if status == genus.status
    return if genus.status == 'valid' && status == 'unidentifiable'
    raise "Genus #{genus.name} status change from #{genus.status} to #{status}"
  end

  def check_existence name, genus
    raise "Genus #{name} not found" unless genus || name == 'Syntaphus'
  end

end
