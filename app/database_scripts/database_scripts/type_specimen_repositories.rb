module DatabaseScripts
  class TypeSpecimenRepositories < DatabaseScript
    def results
      Taxon.where.not(type_specimen_repository: ["", nil])
    end

    def render
      as_table do |t|
        t.header :subspecies, :status, :type_specimen_repository

        t.rows do |taxon|
          [ markdown_taxon_link(taxon), taxon.status, taxon.type_specimen_repository ]
        end
      end
    end
  end
end

__END__
description: >
  This script is just lists of all taxa with a `type_specimen_repository`. See %github207.
topic_areas: [types]
