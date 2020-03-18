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
