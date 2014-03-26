# coding: UTF-8
class Importers::Hol::Catalog

  def compare_with_antcat
    HolComparison.delete_all
    #genus = Genus.find_by_name 'Bilobomyrma'
    for genus in Genus.order(:name_cache).where(status: 'valid').all
      antcat_species = genus.species
      hol_species = species_for_genus genus.name.to_s
      compare_hol_and_antcat_species hol_species, antcat_species
    end
  end

  def species_for_genus genus
    url = "http://osuc.biosci.ohio-state.edu/hymDB/OJ_Break.getTaxaFromText?name=#{genus}&limit=10&nameOnly=N&callback=api"
    string = Curl::Easy.perform(url).body_str
    string.gsub! /^api\((.*)\);$/, '\1'
    hash = JSON.parse string
    return [] if hash['taxa'].empty?
    tnuid = hash['taxa'].first['tnuid']
    url = "http://osuc.biosci.ohio-state.edu/hymDB/OJ_Break.getIncludedTaxa?tnuid=#{tnuid}&showSyns=N&callback=api"
    string = Curl::Easy.perform(url).body_str
    string.gsub! /^api\((.*)\);$/, '\1'
    hash = JSON.parse string
    species = []
    for taxon in hash['includedTaxa']
      species << taxon['name']
    end
    species
  end

  def compare_hol_and_antcat_species hol_species, antcat_species
    hol_index = antcat_index = 0
    while hol_index < hol_species.size && antcat_index < antcat_species.size do
      antcat_name = antcat_species[antcat_index].name.name
      hol_name = hol_species[hol_index]
      if hol_name < antcat_name
        HolComparison.create! name: hol_species[hol_index], status: 'hol'
        hol_index += 1
      elsif hol_name > antcat_name
        HolComparison.create! name: antcat_name, status: 'antcat'
        antcat_index += 1
      else
        HolComparison.create! name: antcat_name, status: 'both'
        antcat_index += 1
        hol_index += 1
      end
    end

    while hol_index < hol_species.size
      HolComparison.create! name: hol_species[hol_index], status: 'hol'
      hol_index += 1
    end

    while antcat_index < antcat_species.size
      HolComparison.create! name: antcat_species[antcat_index].name.name, status: 'antcat'
      antcat_index += 1
    end

  end

end
