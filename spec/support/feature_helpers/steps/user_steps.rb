# frozen_string_literal: true

module FeatureHelpers
  module Steps
    def i_log_in_as name
      login_as User.find_by!(name: name)
    end

    def i_log_in_as_a_user_named name
      login_as create(:user, name: name)
    end

    def i_log_in_as_a_catalog_editor
      login_as create(:user, :editor)
    end

    def i_log_in_as_a_catalog_editor_named name
      login_as create(:user, :editor, name: name)
    end

    def i_log_in_as_a_superadmin_named name
      login_as create(:user, :editor, :superadmin, name: name)
    end
  end
end
