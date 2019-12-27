module DatabaseScripts
  class QuadrinomialsToBeConverted < DatabaseScript
    def results
      Subspecies.joins(:name).where("(LENGTH(names.name) - LENGTH(REPLACE(names.name, ' ', '')) >= 3) ")
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :target_subspecies_name_string, :convertable?, :target_subspecies, :target_subspecies_validation_warnings

        t.rows do |taxon|
          name_string = taxon.name_cache
          target_subspecies_name_string = name_string.split[0..2].join(' ')
          target_subspecies_candiates = Subspecies.where(name_cache: target_subspecies_name_string)

          convertable = target_subspecies_candiates.count == 1
          target_subspecies = target_subspecies_candiates.first

          [
            markdown_taxon_link(taxon),
            taxon.status,
            target_subspecies_name_string,
            ('Yes' if convertable),
            (target_subspecies.link_to_taxon if convertable),
            (format_soft_validation_warnings(target_subspecies) if convertable && target_subspecies.soft_validation_warnings.present?)
          ]
        end
      end
    end

    private

      def format_soft_validation_warnings target_subspecies
        target_subspecies.soft_validation_warnings.map { |warning| warning[:message] }.join('<br><br>')
      end
  end
end

__END__

category: Catalog
tags: []

description: >
  To be converted by script.


  **TODO:**


  * *Done* - Step 1) Convert batch 1: Quadrinomials where a `Subspecies` with the target name exists

  * Step 2) Recreate missing subspecies by script

  * Step 3) Cleanup recreated subspecies (see "Target subspecies has soft validation warnings?")

  * Step 4) Convert batch 2: Quadrinomials where a `Subspecies` with the target name exists after missing subspecies were recreated


  Issues: %github714, %github819

related_scripts:
  - Quadrinomials
  - QuadrinomialsToBeConverted
