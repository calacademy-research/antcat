# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    RECAPTCHA_V3_ACTION = 'registration'

    prepend_before_action :check_recaptcha, only: [:create]
    before_action :configure_permitted_parameters
    before_action :check_if_too_many_registrations_today, only: :create

    def create
      super do |user|
        if user.persisted?
          user.create_activity Activity::CREATE, current_user
        end
      end
    end

    protected

      def configure_permitted_parameters
        devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :name, :password, :password_confirmation])
        devise_parameter_sanitizer.permit(
          :account_update, keys: [
            :email, :name, :author_id, :enable_email_notifications, :password, :password_confirmation, :current_password
          ]
        )
      end

      def update_resource resource, params
        # Require current password if user is trying to change password.
        return super if params[:password].present?

        # Allows user to update registration information without password.
        if params[:password].blank?
          params.except!(:password, :password_confirmation, :current_password)
        end

        if settings_params
          settings_params[:editing_helpers]&.each do |key, value|
            resource.settings(:editing_helpers).public_send("#{key}=", ActiveModel::Type::Boolean.new.cast(value))
          end
        end

        resource.update(params)
      end

      def after_sign_up_path_for _resource
        if (wiki_page = WikiPage.find_by(permanent_identifier: WikiPage::NEW_CONTRIBUTORS_HELP_PAGE))
          wiki_page_path wiki_page
        else
          root_path
        end
      end

    private

      def settings_params
        params.dig(:user, :settings)
      end

      # Via https://github.com/heartcombo/devise/wiki/How-To:-Use-Recaptcha-with-Devise
      def check_recaptcha
        unless recaptcha_v3_valid?(params[:recaptcha_token], Users::RegistrationsController::RECAPTCHA_V3_ACTION)
          self.resource = resource_class.new(sign_up_params)
          resource.validate # Look for any other validation errors besides reCAPTCHA.
          set_minimum_password_length
          respond_with_navigational(resource) { render :new }
        end
      end

      def check_if_too_many_registrations_today
        return unless User.too_many_registrations_today?
        redirect_to root_path, alert: 'Sorry, we have had too many new registrations today. Email us?'
      end
  end
end
