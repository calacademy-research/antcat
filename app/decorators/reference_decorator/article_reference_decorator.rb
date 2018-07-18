class ArticleReferenceDecorator < ReferenceDecorator
  delegate :journal, :series_volume_issue, :pagination

  private

    def format_citation
      "#{h journal.name} #{h series_volume_issue}:#{h pagination}".html_safe
    end
end
