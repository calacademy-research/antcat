# frozen_string_literal: true

# * `#most_recent` - The current item or a reified instance of the most
#   recently deleted version. This is the "owner" of the URL and all revisions.
#
# * `#selected` - Previous revision of the item. If there is a
#   a `selected_id` but no `diff_with_id` = just show that
#   revision without comparing. Always shown to the right when comparing.
#
# * `#diff_with` - Another previous revision. If there is a `diff_with_id`
#   but no `selected_id` = compare with `#most_recent`. Instantiate with both
#   to compare those revisions. This revision will always be older than
#   both `#selected` and `#most_recent`. Always shown to the left when comparing.

class RevisionComparer
  attr_reader :most_recent, :revisions, :selected, :diff_with

  # `id` is the only required argument; it's used for `#most_recent`.
  def initialize klass, id, selected_id = nil, diff_with_id = nil
    @selected_id = selected_id
    @diff_with_id = diff_with_id

    set_most_recent_and_revisions klass, id

    @selected = find_revision selected_id
    @diff_with = find_revision diff_with_id
  end

  def looking_at_most_recent?
    return true if !selected && !diff_with
    !selected
  end

  def looking_at_a_single_old_revision?
    !selected.nil? && !diff_with
  end

  def revision_selected? revision
    revision.id == selected_id.to_i
  end

  def revision_diff_with? revision
    revision.id == diff_with_id.to_i
  end

  private

    attr_reader :selected_id, :diff_with_id

    def set_most_recent_and_revisions klass, id
      @most_recent = klass.find(id)
      @revisions = @most_recent.versions.not_creates
    rescue ActiveRecord::RecordNotFound
      reify_and_set_most_recent_and_revisions klass, id
    end

    # To make deleted object comparable.
    def reify_and_set_most_recent_and_revisions klass, id
      versions = PaperTrail::Version.with_item_keys(klass.name, id)

      # Since we can only get here by following links leading to now deleted
      # taxa, the last version will be the most recent destroy event.
      @most_recent = versions.last.reify

      # Don't include the "destroy" event in the versions (or it shows up twice).
      @revisions = versions.updates
    end

    def find_revision id
      revisions.find(id).reify if id.present?
    end
end
