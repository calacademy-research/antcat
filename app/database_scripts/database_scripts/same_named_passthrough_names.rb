module DatabaseScripts
  class SameNamedPassthroughNames < DatabaseScript
    def results
      Taxon.pass_through_names.
        self_join_on(:current_valid_taxon).
        where("taxa_self_join_alias.name_cache = taxa.name_cache").
        includes(
          :name,
          current_valid_taxon: [:name, protonym: [:name, { authorship: :reference }]],
          protonym: [:name, { authorship: :reference }]
        )
    end

    def render
      as_table do |t|
        t.header :taxon, :author_citation, :status, :current_valid_taxon, :author_citation, :status

        t.rows do |taxon|
          current_valid_taxon = taxon.current_valid_taxon

          [
            markdown_taxon_link(taxon),
            taxon.author_citation,
            taxon.status,
            markdown_taxon_link(taxon),
            current_valid_taxon.author_citation,
            current_valid_taxon.status
          ]
        end
      end
    end
  end
end

__END__
description: >
  See %github283

tags: [regression-test]
topic_areas: [catalog]
