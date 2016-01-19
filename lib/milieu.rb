class Milieu
  def user_can_upload_pdfs? _
    true
  end

  def user_is_editor? user
    user && user.is_editor?
  end

  def user_is_superadmin? user
    user && user.is_superadmin?
  end

  def user_can_edit? user
    user && user.is_editor?
  end

  def user_can_review_changes? user
    user && user.can_review_changes?
  end

  def user_can_approve_changes? user
    user && user.can_approve_changes?
  end
end

$Milieu = Milieu.new
