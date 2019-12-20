module DatabaseScripts
  class QuadrinomialsToBeConverted < DatabaseScript
    def results
      Subspecies.joins(:name).where("(LENGTH(names.name) - LENGTH(REPLACE(names.name, ' ', '')) >= 3) ")
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :target_subspecies_name_string, :convertable?, :target_subspecies

        t.rows do |taxon|
          name_string = taxon.name_cache
          target_subspecies_name_string = name_string.split[0..2].join(' ')
          target_subspecies = Subspecies.where(name_cache: target_subspecies_name_string)

          convertable = target_subspecies.count == 1

          [
            markdown_taxon_link(taxon),
            taxon.status,
            target_subspecies_name_string,
            ('Yes' if convertable),
            (target_subspecies.first.link_to_taxon if convertable)
          ]
        end
      end
    end
  end
end

__END__

category: Catalog
tags: [new!]

description: >
  To be converted by script.


  Batch 1: Quadrinomials where a `Subspecies` with the target name exists.


  Issues: %github714, %github819

related_scripts:
  - Quadrinomials
  - QuadrinomialsToBeConverted
