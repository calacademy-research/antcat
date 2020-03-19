module CompareRevisionsHelper
  # Rescues anything. Trying to render old revisions can raise for many reasons.
  def render_revision_with_rescue item
    render "compare_revision_template", item: item
  rescue StandardError => e
    "Failed to render revision. Thrown error: #{e.message}".html_safe <<
      "<br><br><pre>#{diff_format item}</pre>".html_safe
  end

  # TODO: DRY w.r.t `RevisionComparer#diff_format`.
  def diff_format item
    JSON.pretty_generate JSON.parse(item.to_json)
  end
end
