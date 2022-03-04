# frozen_string_literal: true

class RevisionComparer
  def initialize item_class, item_id, selected_id = nil, diff_with_id = nil
    @item_class = item_class
    @item_id = item_id
    @selected_id = selected_id
    @diff_with_id = diff_with_id
  end

  def most_recent
    @_most_recent ||= live_item || last_live_item
  end

  def selected
    @_selected ||= if selected_id.present?
                     revisions.find(selected_id).reify
                   end
  end

  def diff_with
    @_diff_with ||= if diff_with_id.present?
                      revisions.find(diff_with_id).reify
                    end
  end

  def revisions
    @_revisions ||= if live_item
                      live_item.versions.not_creates
                    else
                      versions.updates
                    end
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

    def last_live_item
      versions.last.reify
    end

    def versions
      @_versions ||= PaperTrail::Version.where(item_type: item_class.name, item_id: item_id)
    end
end
