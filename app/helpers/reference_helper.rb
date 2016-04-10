module ReferenceHelper
  def approve_all_references_button
    return unless user_is_superadmin?

    link_to 'Approve all', approve_all_references_path,
      method: :put, class: "btn-destructive",
      data: { confirm: "Mark all citations as reviewed? This operation cannot be undone!" }
  end
end
