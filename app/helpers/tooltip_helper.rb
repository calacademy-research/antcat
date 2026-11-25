# frozen_string_literal: true

# Tooltips and wiki page icons next to form fields: shows a tooltip from the tooltips table, or a link to add one.
module TooltipHelper
  def db_tooltip_icon key, scope:
    return new_db_tooltip(key, scope) unless (tooltip = Tooltip.find_by(key: key, scope: scope))
    link_to tooltip_icon(tooltip.text), tooltip
  end

  def db_wiki_page_icon permanent_identifier
    wiki_page = WikiPage.from_permanent_identifier_or_missing permanent_identifier
    link_to wiki_page_icon("Related wiki page: #{wiki_page.title}"), wiki_page
  end

  def tooltip_icon text
    tag.span antcat_icon("tooltip-icon"), tooltip2: brs_to_new_lines(text)
  end

  def info_tooltip_icon text
    tag.span antcat_icon("info-tooltip"), tooltip2: brs_to_new_lines(text)
  end

  # For content that which it is not obvious it is hidden to logged-out visitors.
  def logged_in_only_tooltip_icon text = nil, user_group: 'logged-in users'
    title = brs_to_new_lines(text || "This section is only visible to #{user_group}")
    tag.span antcat_icon("info-tooltip"), tooltip2: title
  end

  # A label that links to the policy page behind it, or the plain label while that page does not exist.
  def label_linked_to_wiki_page label, permanent_identifier
    wiki_page = WikiPage.find_by(permanent_identifier: permanent_identifier)
    return label unless wiki_page
    link_to label, wiki_page, title: wiki_page.title
  end

  # One line of links for an editor at work on an etymology, a part of speech or a gender: the policies, the names
  # with notes and the open questions. They open in a new tab, so the form being filled in is not lost.
  def policy_links_for_editors
    identifiers = WikiPage::POLICY_IDENTIFIERS + [WikiPage::OPEN_GRAMMAR_AND_SPELLING_QUESTIONS]
    wiki_pages = WikiPage.where(permanent_identifier: identifiers).index_by(&:permanent_identifier)
    links = [
      [WikiPage::GRAMMAR_AND_SPELLING_POLICY, "Policy on grammar and spelling"],
      [WikiPage::DERIVED_ETYMOLOGIES_POLICY, "Policy on derived etymologies"]
    ].filter_map { |identifier, label| [label, wiki_pages[identifier]] if wiki_pages[identifier] }
    links << ["Names with notes", notes_pages_path]
    if (open_questions = wiki_pages[WikiPage::OPEN_GRAMMAR_AND_SPELLING_QUESTIONS])
      links << ["Open questions", open_questions]
    end

    tag.div class: "text-sm", data: { testid: 'policy-links-for-editors' } do
      safe_join(links.map { |label, target| link_to(label, target, target: "_blank", rel: "noopener") }, " · ")
    end
  end

  def link_to_wiki_page_or_missing permanent_identifier
    wiki_page = WikiPage.from_permanent_identifier_or_missing permanent_identifier
    link_to wiki_page.title, wiki_page
  end

  private

    def wiki_page_icon text
      tag.span antcat_icon("wiki-page-icon"), tooltip2: brs_to_new_lines(text)
    end

    def new_db_tooltip key, scope
      text = "Could not find tooltip with key '#{key}' with page scope '#{scope}'. Click icon to create."
      link_to tooltip_icon(text), new_tooltip_path(key: key, scope: scope)
    end

    # https://stackoverflow.com/questions/3340802/add-line-break-within-tooltips
    def brs_to_new_lines text
      sanitize text.gsub(%r{<br ?/?>}, '&#013;&#010;')
    end
end
