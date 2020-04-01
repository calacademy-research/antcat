# frozen_string_literal: true

require "diffy"

class RevisionPresenter
  ATTRIBUTES_IGNORED_IN_DIFF = %i[
    formatted_cache
    inline_citation_cache
    principal_author_last_name_cache
    plain_text_cache
    expandable_reference_cache
    expanded_reference_cache
  ]

  attr_private_initialize [:comparer, template: nil]

  def show_formatted?
    @_show_formatted ||= template.present?
  end

  def left_side_diff
    html_split_diff.left
  end

  def right_side_diff
    html_split_diff.right
  end

  # This is for the `revisions` loop, ie `most_recent` is not handled here.
  def revision_css revision
    # If `revision.id` isn't opened in `selected` or `diff_with`, that means user is not comparing
    # revisions or looking at an old revision --> do not highlight.
    return unless comparer.revision_selected?(revision) || comparer.revision_diff_with?(revision)

    # User is looking at an old revision without comparig --> highlight
    # in red to indicate that it's an old revision.
    return "make-red" if comparer.looking_at_a_single_old_revision?

    # User is comparing --> highlight the oldest revision red
    # and the more recent (`selected_id`) green.
    if comparer.revision_selected? revision
      "make-green"
    else
      "make-red"
    end
  end

  # Rescues anything. Rendering old revisions can raise for many reasons.
  def render_revision_with_rescue item, view_context:
    view_context.render template, item: item
  rescue ActionView::MissingTemplate
    raise
  rescue StandardError => e
    "Failed to render revision. Thrown error: #{e.message}".html_safe <<
      "<br><br><pre>#{diff_format(item)}</pre>".html_safe
  end

  private

    delegate :selected, :diff_with, :most_recent, to: :comparer

    def html_split_diff
      return unless diff_with

      @_html_split_diff ||= begin
        left = diff_format diff_with
        right = diff_format selected || most_recent
        Diffy::SplitDiff.new(left, right, format: :html)
      end
    end

    def diff_format item
      as_json = item.as_json(except: ATTRIBUTES_IGNORED_IN_DIFF)
      JSON.pretty_generate(as_json)
    end
end
