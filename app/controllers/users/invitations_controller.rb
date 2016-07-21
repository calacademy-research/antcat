class Users::InvitationsController < Devise::InvitationsController
  def after_invite_path_for resource
    new_user_invitation_path
  end

  protected
    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:accept_invitation).concat [:email, :name]
      devise_parameter_sanitizer.for(:accept_invitation) do |u|
        u.permit(:email, :name, :password, :password_confirmation, :invitation_token)
      end
    end
end
