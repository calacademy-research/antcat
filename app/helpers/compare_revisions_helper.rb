module CompareRevisionsHelper
  # Rescues anything. Trying to render old revisions can raise for many reasons.
  def render_revision_with_rescue item
    render "compare_revision_template", item: item
  rescue => error
    "Failed to render revision. Thrown error: #{error.message}"
  end
end
