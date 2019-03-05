class ArticleReferenceDecorator < ReferenceDecorator
  delegate :journal, :series_volume_issue, :pagination

  private

    def format_citation
      sanitize "#{journal.name} #{series_volume_issue}:#{pagination}"
    end
end
