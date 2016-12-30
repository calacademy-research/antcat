class ArticleReferenceDecorator < ReferenceDecorator
  delegate_all

  private
    def format_citation
      citation = "#{h reference.journal.name} #{h reference.series_volume_issue}:#{h reference.pagination}"
      format_italics helpers.add_period_if_necessary citation.html_safe
    end
end
