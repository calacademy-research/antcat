module DatabaseScripts
  module ViewHelpers
    def taxa_list taxa
      taxa.map(&:link_to_taxon).join('<br>')
    end
  end
end
