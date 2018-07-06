module DatabaseScripts
  class SpeciesAndSubspeciesWithSynonymsNotInTheSameGenus < DatabaseScript
    def senior_synonyms
      Taxon.where(type: ['Species', 'Subspecies']).joins(:junior_synonyms)
        .where('junior_synonyms_taxa.genus_id != taxa.genus_id').distinct
    end

    def junior_synonyms
      Taxon.where(type: ['Species', 'Subspecies']).joins(:senior_synonyms)
        .where('senior_synonyms_taxa.genus_id != taxa.genus_id').distinct
    end

    def render
      as_table do |t|
        t.header :senior, :status, :juniors

        t.rows(senior_synonyms) do |taxon|
          [
            markdown_taxon_link(taxon),
            taxon.status,
            markdown_taxa_links(taxon, taxon.junior_synonyms)
          ]
        end
      end <<

        as_table do |t|
          t.header :junior, :status, :senior

          t.rows(junior_synonyms) do |taxon|
            [
              markdown_taxon_link(taxon),
              taxon.status,
              markdown_taxa_links(taxon, taxon.senior_synonyms)
            ]
          end
        end
    end

    private
      def markdown_taxa_links taxon, taxa
        taxa.where.not(genus_id: taxon.genus_id).map do |taxon|
          markdown_taxon_link(taxon)
        end.join(', ')
      end
  end
end

__END__
description: >
  The upper table is for seniors with juniors not in the same genus;
  the lower table lists juniors with seniors not in the same genus
  (ie, the tables contain the same data, but they are kind of inverted).


  See %github237.

tags: [new!]
topic_areas: [synonyms]
