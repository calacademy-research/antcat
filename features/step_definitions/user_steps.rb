# frozen_string_literal: true

def login_programmatically user
  login_as user, scope: :user, run_callbacks: false
end

def i_log_in_as name
  user = User.find_by!(name: name)
  login_programmatically user
end

def i_log_in_as_a_user_named name
  user = create :user, name: name
  login_programmatically user
end

def i_log_in_as_a_catalog_editor
  user = create :user, :editor
  login_programmatically user
end

def i_log_in_as_a_catalog_editor_named name
  user = create :user, :editor, name: name
  login_programmatically user
end

def i_log_in_as_a_superadmin_named name
  user = create :user, :editor, :superadmin, name: name
  login_programmatically user
end
