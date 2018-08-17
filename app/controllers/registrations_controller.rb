class RegistrationsController < Devise::RegistrationsController
  protected

    def update_resource resource, params
      # Require current password if user is trying to change password.
      return super if params[:password].present?

      # Allows user to update registration information without password.
      if params[:password].blank?
        params.delete(:password)
        params.delete(:password_confirmation)
        params.delete(:current_password)
      end

      resource.update params
    end

    def after_sign_up_path_for _resource
      root_path
    end
end
