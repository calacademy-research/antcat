class DatabaseScripts::Scripts::TypeSpecimenRepositories
  include DatabaseScripts::DatabaseScript

  def results
    Taxon.where.not(type_specimen_repository: ["", nil])
  end

  def render
    as_table do
      header :subspecies, :status, :type_specimen_repository
      rows do |taxon|
        [ markdown_taxon_link(taxon), taxon.status, taxon.type_specimen_repository ]
      end
    end
  end
end

__END__
description: >
  This script is just lists of all taxa with a `type_specimen_repository`. See %github207.
topic_areas: [types]
