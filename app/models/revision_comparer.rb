# frozen_string_literal: true

class RevisionComparer
  attr_reader :most_recent, :revisions, :selected, :diff_with

  def initialize item_class, item_id, selected_id = nil, diff_with_id = nil
    @item_class = item_class
    @item_id = item_id
    @selected_id = selected_id
    @diff_with_id = diff_with_id

    set_most_recent_and_revisions

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

  # TODO: Probably move this and `#revision_diff_with?` to `RevisionPresenter`.
  def revision_selected? revision
    revision.id == selected_id.to_i
  end

  def revision_diff_with? revision
    revision.id == diff_with_id.to_i
  end

  private

    attr_reader :item_class, :item_id, :selected_id, :diff_with_id

    def set_most_recent_and_revisions
      @most_recent = item_class.find(item_id)
      @revisions = @most_recent.versions.not_creates
    rescue ActiveRecord::RecordNotFound
      reify_and_set_most_recent_and_revisions
    end

    # To make deleted object comparable.
    def reify_and_set_most_recent_and_revisions
      versions = PaperTrail::Version.with_item_keys(item_class.name, item_id)

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
