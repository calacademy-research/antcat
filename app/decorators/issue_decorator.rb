# frozen_string_literal: true

class IssueDecorator < Draper::Decorator
  def icon
    h.antcat_icon "issue", issue.open? ? 'open' : 'closed'
  end

  def help_wanted_badge
    return unless issue.help_wanted? && issue.open?
    h.tag.span "Help wanted!", class: "rounded-badge high-priority-label"
  end
end
