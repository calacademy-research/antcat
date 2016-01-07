module ReferenceHelper
  def approve_all_button
    if $Milieu.user_is_superadmin? current_user
      button 'Approve all', 'approve_all_button', class: 'approve_all'
    end
  end
end
