# frozen_string_literal: true

module My
  class RegistrationsController < Devise::RegistrationsController
    RECAPTCHA_V3_ACTION = 'registration'

    prepend_before_action :check_recaptcha, only: [:create]
    before_action :check_if_too_many_registrations_today, only: :create

    invisible_captcha only: [:create], honeypot: :work_email, on_spam: :on_spam

    def create
      super do |user|
        if user.persisted?
          user.create_activity :create, current_user
        end
      end
    end

    protected

      def update_resource resource, params
        # Require current password if user is trying to change password.
        return super if params[:password].present?

        # Allows user to update registration information without password.
        if params[:password].blank?
          params.except!(:password, :password_confirmation, :current_password)
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

      # Via https://github.com/heartcombo/devise/wiki/How-To:-Use-Recaptcha-with-Devise
      def check_recaptcha
        unless recaptcha_v3_valid?(params[:recaptcha_token], My::RegistrationsController::RECAPTCHA_V3_ACTION)
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

      def on_spam _options = {}
        redirect_to root_path, alert: "You're not a bot are you? Email us?"
      end
  end
end
