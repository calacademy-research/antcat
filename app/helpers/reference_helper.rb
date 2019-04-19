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

  def set_as_default_reference_button reference
    if reference == DefaultReference.get(session)
      content_tag :span, 'Default reference', class: "btn-nodanger btn-tiny",
        title: "This referece is set as the default reference."
    else
      link_to 'Make default', my_default_reference_path(id: reference.id),
        method: :put, class: "btn-saves btn-tiny"
    end
  end

  def reference_tab_active? reference, reference_class
    "is-active" if reference.is_a? reference_class
  end
end
