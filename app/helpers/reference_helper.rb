module ReferenceHelper
  def approve_all_references_button
    return unless user_is_superadmin?

    link_to 'Approve all', approve_all_reviewing_references_path,
      method: :put, class: "btn-saves-warning",
      data: { confirm: "Mark all citations as reviewed? This operation cannot be undone!" }
  end

  def review_reference_button reference
    if reference.can_finish_reviewing?
      link_to 'Finish reviewing', finish_reviewing_reference_path(reference),
        method: :post, class: "btn-saves",
        data: { confirm: "Have you finished reviewing this reference?" }
    elsif reference.can_start_reviewing?
      link_to 'Start reviewing', start_reviewing_reference_path(reference),
        method: :post, class: "btn-saves",
        data: { confirm: 'Are you ready to start reviewing this reference?' }
    elsif reference.can_restart_reviewing?
      link_to 'Restart reviewing', restart_reviewing_reference_path(reference),
        method: :post, class: "btn-saves-warning",
        data: { confirm: 'Do you want to start reviewing this reference again?' }
    end
  end

  def set_as_default_reference reference
    if reference == DefaultReference.get(session)
      'Default'
    else
      link_to 'Make default', default_reference_path(id: reference.id),
        method: :put, class: "btn-saves"
    end
  end

  def references_subnavigation_links
    links = []
    links << link_to('All References', references_path)
    links << link_to('Latest Additions', references_latest_additions_path)
    links << link_to('Latest Changes', references_latest_changes_path)

    if user_can_edit?
      # TODO probably allow anyone to export search results.
      if show_export_search_results_to_endnote?
        links << link_to('Export to EndNote', endnote_export_references_path(q: params[:q]))
      end
    end

    links << link_to('Journals', journals_path)
    links << link_to('Authors', authors_path)

    links
  end

  def reference_tab_active? reference, reference_class
    "is-active" if reference.is_a? reference_class
  end

  private

    def show_export_search_results_to_endnote?
      params[:action] == "search"
    end
end
