class DatabaseScripts::Scripts::ProtonymsWithReferencesMissingYear
  include DatabaseScripts::DatabaseScript

  def results
    Protonym.joins(authorship: :reference).where("references.year IS NULL")
  end

  def render
    as_table do
      header :taxon, :status, :reference

      rows do |protonym|
        [ markdown_taxon_link(protonym.taxon),
          protonym.taxon.status,
          markdown_reference_link(protonym.authorship.reference) ]
      end
    end
  end
end

__END__
description: >
  * All protonyms have authorships: `Protonym.where(authorship: nil).count # 0`

  * New protonyms cannot be created without a reference, but there are 16 of them in the db.

  * Stats (June 2017):

      `Protonym.count                                         # 24512`
      `joined = Protonym.joins(authorship: :reference)`
      `joined.where("references.year IS NOT NULL").count      # 24635`
      `joined.where("references.year IS NULL").count          # 16`
topic_areas: [catalog, references]
