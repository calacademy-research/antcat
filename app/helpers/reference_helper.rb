module ReferenceHelper
  def approve_all_references_button
    return unless user_is_superadmin?

    link_to append_superadmin_icon("Approve all"), approve_all_reviewing_references_path,
      method: :put, class: "btn-warning",
      data: { confirm: "Mark all citations as reviewed? This operation cannot be undone!" }
  end

  def review_reference_button reference
    if reference.can_finish_reviewing?
      link_to 'Finish reviewing', finish_reviewing_reference_path(reference),
        method: :post, class: "btn-saves btn-tiny",
        data: { confirm: "Have you finished reviewing this reference?" }
    elsif reference.can_start_reviewing?
      link_to 'Start reviewing', start_reviewing_reference_path(reference),
        method: :post, class: "btn-saves btn-tiny",
        data: { confirm: 'Are you ready to start reviewing this reference?' }
    elsif reference.can_restart_reviewing?
      link_to 'Restart reviewing', restart_reviewing_reference_path(reference),
        method: :post, class: "btn-warning btn-tiny",
        data: { confirm: 'Do you want to start reviewing this reference again?' }
    end
  end

  def set_as_default_reference_button reference, very_tiny: false
    css_classes = very_tiny ? "btn-very-tiny" : "btn-tiny"

    if reference == DefaultReference.get(session)
      content_tag :span, 'Default reference', class: (css_classes << " btn-nodanger"),
        title: "This referece is set as the default reference."
    else
      link_to 'Make default', default_reference_path(id: reference.id),
        method: :put, class: (css_classes << " btn-saves")
    end
  end

  def show_references_subnavigation?
    request.path.in?(
      [
        references_path,
        references_latest_additions_path,
        references_latest_changes_path,
        endnote_export_references_path,
        journals_path, authors_path
      ]
    )
  end

  def references_subnavigation_menu
    links = []
    links << link_to('All References', references_path)
    links << link_to('Latest Additions', references_latest_additions_path)
    links << link_to('Latest Changes', references_latest_changes_path)
    links << link_to('Journals', journals_path)
    links << link_to('Authors', authors_path)

    content_tag :span do |_content|
      links.flatten.reduce(''.html_safe) do |string, item|
        string << ' '.html_safe unless string.empty?
        string << item
      end
    end
  end

  def reference_tab_active? reference, reference_class
    "is-active" if reference.is_a? reference_class
  end
end
