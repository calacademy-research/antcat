# frozen_string_literal: true

# Formats an issue of the editors' list: open or closed icon and the "Help wanted!" badge.
class IssueDecorator < Draper::Decorator
  def icon
    h.antcat_icon "issue", issue.open? ? 'open' : 'closed'
  end

  def help_wanted_badge
    return unless issue.help_wanted? && issue.open?
    h.tag.span "Help wanted!", class: "badge-orange"
  end
end
