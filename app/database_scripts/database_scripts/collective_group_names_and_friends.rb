module DatabaseScripts
  class CollectiveGroupNamesAndFriends < DatabaseScript
    def results
      collective_group_names = Taxon.where(status: Status::COLLECTIVE_GROUP_NAME)
      as_current_valid_taxon = Taxon.where(current_valid_taxon: collective_group_names)
      as_species = Taxon.where(genus_id: collective_group_names)

      Taxon.where(id: collective_group_names + as_current_valid_taxon + as_species)
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :collective_group_name?
        t.rows do |taxon|
          [markdown_taxon_link(taxon), taxon.status, taxon.collective_group_name]
        end
      end
    end
  end
end

__END__

description: >
  Edit the "friends" first, since they will disappear from this list once
  the status of the collective group name they are referencing is changed.


  `collective_group_name?` refers to the new parallel status.

tags: [new!]
topic_areas: [catalog]
