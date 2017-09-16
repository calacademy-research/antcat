module DatabaseScripts
  class NonDisplayableObsoleteCombinations < DatabaseScript
    def results
      Taxon.where(display: false, status: "obsolete combination")
    end

    def render
      as_table do |t|
        t.header :taxon, :status, :display

        t.rows { |taxon| [ markdown_taxon_link(taxon), taxon.status, taxon.display ] }
      end
    end
  end
end

__END__
description: >
  Obsolete combinations where `display` is false.
  If everything checks out, I'll change all of these so that `display`
  is set to true. See %github21.
topic_areas: [catalog]
