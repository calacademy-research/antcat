module My
  class RegistrationsController < Devise::RegistrationsController
    def create
      super do |user|
        if user.persisted?
          user.create_activity :create
        end
      end
    end

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

        resource.update(params)
      end

      # TODO: Create welcome page for new contributors.
      def after_sign_up_path_for _resource
        root_path
      end
  end
end
