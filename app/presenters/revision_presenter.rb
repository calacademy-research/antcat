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

  def initialize comparer:, hide_formatted: false
    @comparer = comparer
    @hide_formatted = hide_formatted
  end

  def hide_formatted?
    hide_formatted
  end

  def html_split_diff
    return unless diff_with

    left = diff_format diff_with
    right = diff_format selected || most_recent

    Diffy::SplitDiff.new(left, right, format: :html)
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
    view_context.render "compare_revision_template", item: item
  rescue StandardError => e
    "Failed to render revision. Thrown error: #{e.message}".html_safe <<
      "<br><br><pre>#{diff_format(item)}</pre>".html_safe
  end

  private

    delegate :selected, :diff_with, :most_recent, to: :comparer

    attr_reader :comparer, :hide_formatted

    def diff_format item
      json = to_json item
      JSON.pretty_generate JSON.parse(json)
    end

    # HACK: To make the diff less cluttered.
    def to_json item
      item.to_json(except: ATTRIBUTES_IGNORED_IN_DIFF)
    end
end
