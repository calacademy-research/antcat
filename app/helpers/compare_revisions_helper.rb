module CompareRevisionsHelper
  # Rescues anything. Trying to render old revisions can raise for many reasons.
  def render_revision_with_rescue item
    render "compare_revision_template", item: item
  rescue StardardError => e
    "Failed to render revision. Thrown error: #{e.message}".html_safe <<
      "<br><br><pre>#{diff_format item}</pre>".html_safe
  end

  # TODO DRY w.r.t `RevisionComparer#diff_format`.
  def diff_format item
    JSON.pretty_generate JSON.parse(item.to_json)
  end

  # This is for the `revisions` loop, ie `most_recent` is not handled here.
  def revision_css comparer, revision
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
end
