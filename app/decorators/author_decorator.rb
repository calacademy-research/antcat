class AuthorDecorator < Draper::Decorator
  delegate :references, :described_taxa

  def published_between
    first_year = references.minimum(:year)
    most_recent_year = references.maximum(:year)

    return first_year if first_year == most_recent_year
    "#{first_year}&ndash;#{most_recent_year}".html_safe
  end

  def taxon_descriptions_between
    return unless described_taxa.exists?

    taxa = described_taxa.order("references.year, references.id")

    first_year = description_year taxa.first
    most_recent_year = description_year taxa.last

    return first_year if first_year == most_recent_year
    "#{first_year}&ndash;#{most_recent_year}".html_safe
  end

  private

    def description_year taxon
      taxon.authorship_reference.year
    end
end
