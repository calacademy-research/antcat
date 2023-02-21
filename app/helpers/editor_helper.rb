# frozen_string_literal: true

module EditorHelper
  def hide_editing_helper_link
    tag.div class: 'show-editing-helper text-sm float-right show-on-hover' do
      link_to "Hide editing helper", edit_user_registration_path
    end
  end

  def enable_editing_helper_link
    tag.div class: 'text-sm' do
      concat "Enable editing helper on "
      concat link_to "My account", edit_user_registration_path
    end
  end
end
