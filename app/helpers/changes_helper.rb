module ChangesHelper
  def confirm_before_undo_button change
    return unless user_is_editor?
    link_to 'Undo...', change_undos_path(change), class: "btn-warning btn-tiny"
  end

  def approve_all_changes_button
    return unless user_is_superadmin?

    link_to append_superadmin_icon("Approve all"), approve_all_changes_path,
      method: :put, class: "btn-warning",
      data: { confirm: "Are you sure you want to approve all changes?" }
  end

  # TODO copy-pasted from `ChangesDecorator`.
  def format_change_type_verb change_type
    case change_type
    when "create" then "added"
    when "delete" then "deleted"
    else               "changed"
    end
  end
end
