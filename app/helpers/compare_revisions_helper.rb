module CompareRevisionsHelper
  # Rescues anything. Trying to render old revisions can raise for many reasons.
  def render_revision_with_rescue item
    render "compare_revision_template", item: item
  rescue => error
    "Failed to render revision. Thrown error: #{error.message}".html_safe <<
    "<br><br><pre>#{diff_format item}</pre>".html_safe
  end

  # TODO DRY w.r.t `RevisionComparer#diff_format`.
  def diff_format item
    JSON.pretty_generate JSON.parse(item.to_json)
  end

  def most_recent_selected?
    params[:selected_id].blank?
  end

  # This is for the `revisions` loop, ie `most_recent` is not handled here.
  def revision_css revision
    # If `revision.id` isn't in any param, that means user is not comparing
    # revisions or looking at an old revision --> do not highlight.
    return unless revision_in_any_param? revision

    # User is looking at an old revision without comparig --> highlight
    # in red to indicate that it's an old revision.
    return "make-red" if looking_at_an_old_revision?

    # User is comparing --> highlight the oldest revision red
    # and the other (`selected_id`) green.
    if revision_in_param? revision, :selected_id
      "make-green"
    else
      "make-red"
    end
  end

  def revision_in_param? revision, radio_name
    revision.id.to_s == params[radio_name]
  end

  def looking_at_an_old_revision?
    params[:selected_id].present? && params[:diff_with_id].blank?
  end

  def try_to_link_revision_history type, id
    url = RevisionHistoryPath.new(type, id).call
    return unless url

    link_to "History", url, class: "btn-normal btn-tiny"
  end

  private
    def revision_in_any_param? revision
      revision_in_param?(revision, :selected_id) ||
        revision_in_param?(revision, :diff_with_id)
    end
end
