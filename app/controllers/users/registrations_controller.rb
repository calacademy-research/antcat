# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    RECAPTCHA_V3_ACTION = 'registration'
    # Settings keys users may change via `user[settings][editing_helpers][<key>]`.
    EDITING_HELPERS_SETTINGS_KEYS = %w[create_combination].freeze

    prepend_before_action :check_recaptcha, only: [:create]
    before_action :configure_permitted_parameters

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

      # Changing the email or password requires the current password (Devise's `update_with_password`).
      # Other account details and preferences can be updated without it.
      def update_resource resource, params
        assign_editing_helpers_settings resource

        return super if params[:password].present? || email_changing?(resource, params)

        params.except!(:password, :password_confirmation, :current_password)
        resource.update(params)
      end

      def after_sign_up_path_for _resource
        if (wiki_page = WikiPage.find_by(permanent_identifier: WikiPage::NEW_CONTRIBUTORS_HELP_PAGE))
          wiki_page_path wiki_page
        else
          root_path
        end
      end

      def after_update_path_for _resource
        edit_user_registration_path
      end

    private

      def email_changing? resource, params
        return false unless params.key?(:email)
        params[:email].to_s.strip.downcase != resource.email.to_s.downcase
      end

      # Only keys in `EDITING_HELPERS_SETTINGS_KEYS` are used; others are ignored.
      def assign_editing_helpers_settings resource
        editing_helpers = params.dig(:user, :settings, :editing_helpers)
        return unless editing_helpers.is_a?(ActionController::Parameters)

        EDITING_HELPERS_SETTINGS_KEYS.each do |key|
          value = editing_helpers[key]
          next unless value.is_a?(String)

          resource.settings(:editing_helpers).public_send(:"#{key}=", ActiveModel::Type::Boolean.new.cast(value))
        end
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
  end
end
