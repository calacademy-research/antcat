# frozen_string_literal: true

class RevisionComparer
  attr_reader :most_recent, :revisions, :selected, :diff_with

  def initialize item_class, item_id, selected_id = nil, diff_with_id = nil
    @item_class = item_class
    @item_id = item_id
    @selected_id = selected_id
    @diff_with_id = diff_with_id

    if live_item
      @most_recent = live_item
      @revisions = live_item.versions.not_creates
    else
      versions = PaperTrail::Version.where(item_type: item_class.name, item_id: item_id)
      @most_recent = versions.last.reify
      @revisions = versions.updates
    end

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

    def live_item
      return @_live_item if defined?(@_live_item)
      @_live_item = item_class.find_by(id: item_id)
    end

    def find_revision id
      revisions.find(id).reify if id.present?
    end
end
