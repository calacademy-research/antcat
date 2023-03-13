# frozen_string_literal: true

class RevisionPresenter
  REMOVED_REFERENCE_CACHE_COLUMNS = %i[
    formatted_cache
    inline_citation_cache
    principal_author_last_name_cache
    expandable_reference_cache
  ]
  ATTRIBUTES_IGNORED_IN_DIFF = REMOVED_REFERENCE_CACHE_COLUMNS + Reference::CACHE_COLUMNS

  attr_private_initialize [:comparer, { template: nil }]

  def left_side_diff
    html_split_diff.left
  end

  def right_side_diff
    html_split_diff.right
  end

  def revision_css revision
    return unless comparer.revision_selected?(revision) || comparer.revision_diff_with?(revision)

    return "bg-revision-red" if comparer.looking_at_a_single_old_revision?

    if comparer.revision_selected? revision
      "bg-revision-green"
    else
      "bg-revision-red"
    end
  end

  def render_revision item, view_context:
    if template
      render_revision_with_template(item, view_context: view_context)
    else
      "<pre>#{revision_as_json(item)}</pre>".html_safe
    end
  end

  private

    # Rescues anything. Rendering old revisions can raise for many reasons.
    def render_revision_with_template item, view_context:
      view_context.render template, item: item
    rescue ActionView::MissingTemplate
      raise
    rescue StandardError => e
      "Failed to render revision. Thrown error: #{e.message}".html_safe <<
        "<br><br><pre>#{revision_as_json(item)}</pre>".html_safe
    end

    def html_split_diff
      return unless comparer.diff_with

      @_html_split_diff ||= begin
        left = revision_as_json(comparer.diff_with)
        right = revision_as_json(comparer.selected || comparer.most_recent)
        Diffy::SplitDiff.new(left, right, format: :html)
      end
    end

    def revision_as_json item
      as_json = item.as_json(except: ATTRIBUTES_IGNORED_IN_DIFF)
      JSON.pretty_generate(as_json.compact_blank)
    end
end
