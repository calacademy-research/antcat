# TODO make it possible diff any revisions, ie not just
# comparing the selected revision with the current.
# TODO find a better name for `#current`.

require "diffy"

class RevisionComparer
  attr_reader :current, :revisions

  def initialize klass, id, selected_id = nil
    @selected_id = selected_id
    set_current_and_revisions klass, id
  end

  def selected
    return unless @selected_id
    @selected ||= revisions.find(@selected_id).reify
  end

  def html_split_diff
    return unless selected
    Diffy::SplitDiff.new diff_format(selected), diff_format(@current), format: :html
  end

  private
    def set_current_and_revisions klass, id
      @current = klass.find id
      @revisions = @current.versions.not_creates

    rescue ActiveRecord::RecordNotFound
      reify_and_set_current_and_revisions klass, id
    end

    # To make deleted object comparable.
    def reify_and_set_current_and_revisions klass, id
      versions = PaperTrail::Version.with_item_keys(klass, id)

      # Since we can only get here by following links leading to now deleted
      # taxa, the last version will be the most recent destroy event.
      @current = versions.last.reify

      # Don't include the "destroy" event in the versions (or it shows up twice).
      @revisions = versions.updates
    end

    def diff_format item
      JSON.pretty_generate JSON.parse(item.to_json)
    end
end
