# frozen_string_literal: true

module DatabaseScripts
  class ProtonymsWithDuplicatedTaxa < DatabaseScript
    def results
      Protonym.joins(:taxa).group('protonyms.id, taxa.name_cache').having('COUNT(*) > 1')
    end

    def render
      as_table do |t|
        t.header 'Protonym', 'Authorship', 'Statuses of taxa'
        t.rows do |protonym|
          [
            protonym.decorate.link_to_protonym,
            protonym.authorship.reference.keey,
            protonym.taxa.pluck(:name_cache).join('<br>')
          ]
        end
      end
    end
  end
end

__END__

category: Protonyms
tags: [regression-test]

issue_description: This protonym has duplicated taxa.
