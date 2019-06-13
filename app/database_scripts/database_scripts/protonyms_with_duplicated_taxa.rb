module DatabaseScripts
  class ProtonymsWithDuplicatedTaxa < DatabaseScript
    def results
      Protonym.joins(:taxa).group('protonyms.id, taxa.name_cache').having('COUNT(*) > 1')
    end

    def render
      as_table do |t|
        t.header :protonym, :authorship, :statuses_of_taxa
        t.rows do |protonym|
          [
            link_to(protonym.decorate.format_name, protonym_path(protonym)),
            protonym.authorship.reference.decorate.expandable_reference,
            protonym.taxa.pluck(:name_cache).join('<br>')
          ]
        end
      end
    end
  end
end

__END__

tags: [regression-test]
topic_areas: [protonyms]
