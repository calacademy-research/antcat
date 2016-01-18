module ReferenceHelper
  def approve_all_references_button
    return unless $Milieu.user_is_superadmin? current_user

    link_to 'Approve all', approve_all_references_path,
      method: :put, class: "btn-destructive",
      data: { confirm: "Mark all citations as reviewed? This operation cannot be undone!" }
  end
end
