class ArticleReferenceDecorator < ReferenceDecorator
  delegate_all

  private
    def format_citation
      "#{h reference.journal.name} #{h reference.series_volume_issue}:#{h reference.pagination}".html_safe
    end
end
