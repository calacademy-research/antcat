# frozen_string_literal: true

module Users
  # Sign-up in two steps, so the response never shows whether an email address already has an account:
  #
  # 1. `create` (the sign-up form: email and name) always answers with the same message. A new address
  #    gets an email with a signed link (valid for `SIGN_UP_LINK_VALID_FOR`); an address that already has
  #    an account gets a notice with links to sign in or reset the password. Nothing is saved.
  #    Only checks that do not depend on who has an account run here (email format, name present and
  #    without `<>`). "Name has already been taken" is checked in step 2: checked here, it would stop
  #    a person with an account who types their own name from getting the notice, and an error shown
  #    for a new address but not for a registered one would tell anyone which addresses are registered.
  # 2. `complete` / `finish` (from the emailed link): the person chooses a password (and can change the
  #    name, for example when it was taken in the meantime), the account is created and signed in.
  #
  # The account is only created by someone who can read the address's email.
  class RegistrationsController < Devise::RegistrationsController
    include RequestThrottle

    RECAPTCHA_V3_ACTION = 'registration'
    # Settings keys users may change via `user[settings][editing_helpers][<key>]`.
    EDITING_HELPERS_SETTINGS_KEYS = %w[create_combination].freeze
    SIGN_UPS_PER_IP = 5
    SIGN_UPS_PER_EMAIL = 3
    SIGN_UPS_WITHIN = 1.hour
    TOO_MANY_SIGN_UPS_MESSAGE = "Too many sign-up attempts. Please wait a while and try again."
    SIGN_UP_LINK_VALID_FOR = 24.hours
    SIGN_UP_TOKEN_PURPOSE = :sign_up
    SIGN_UP_EMAIL_SENT_MESSAGE = "Thank you. If this email address can be used for a new account, you will receive an email with a link to finish signing up in a few minutes."
    INVALID_SIGN_UP_LINK_MESSAGE = "This sign-up link is invalid or has expired. Please sign up again."
    ALREADY_REGISTERED_MESSAGE = 'This email address already has an account. Please log in, or use "Forgot password?" on the login page.'

    prepend_before_action :require_no_authentication, only: [:complete, :finish]
    prepend_before_action :check_recaptcha, only: [:create]
    prepend_before_action :throttle_sign_up, only: [:create] # Prepended last, so it runs first.
    before_action :configure_permitted_parameters
    before_action :load_sign_up_from_token, only: [:complete, :finish]

    def self.sign_up_token email:, name:
      sign_up_verifier.generate(
        { 'email' => email, 'name' => name },
        purpose: SIGN_UP_TOKEN_PURPOSE, expires_in: SIGN_UP_LINK_VALID_FOR
      )
    end

    def self.sign_up_verifier
      Rails.application.message_verifier(:user_sign_up)
    end

    # Step 1. Same response for new and already registered addresses. The form's errors (blank or invalid
    # email, blank name) do not depend on the address being registered, so they are shown for both.
    def create
      self.resource = build_sign_up_resource
      if resource.errors.any?
        clean_up_passwords resource
        set_minimum_password_length
        render :new, status: :unprocessable_content
        return
      end

      send_sign_up_email resource
      redirect_to root_path, notice: SIGN_UP_EMAIL_SENT_MESSAGE
    end

    # Step 2: the page the emailed link opens.
    def complete
      self.resource = resource_class.new(email: @sign_up[:email], name: @sign_up[:name])
      resource.errors.add(:name, :taken) if name_taken?(resource.name)
      set_minimum_password_length
    end

    def finish
      self.resource = resource_class.new(
        email: @sign_up[:email],
        name: params.dig(:user, :name).presence || @sign_up[:name],
        password: params.dig(:user, :password),
        password_confirmation: params.dig(:user, :password_confirmation)
      )

      if save_new_user(resource)
        resource.create_activity Activity::CREATE, nil
        set_flash_message! :notice, :signed_up
        sign_up resource_name, resource
        redirect_to after_sign_up_path_for(resource)
      elsif email_registered?(resource.email)
        redirect_to new_user_session_path, alert: ALREADY_REGISTERED_MESSAGE
      else
        clean_up_passwords resource
        set_minimum_password_length
        render :complete, status: :unprocessable_content
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

      def throttle_sign_up
        throttled = request_throttled?(
          "sign_up",
          per_ip: SIGN_UPS_PER_IP, per_email: SIGN_UPS_PER_EMAIL,
          within: SIGN_UPS_WITHIN, email: params.dig(:user, :email)
        )
        redirect_to new_user_registration_path, alert: TOO_MANY_SIGN_UPS_MESSAGE if throttled
      end

      # Via https://github.com/heartcombo/devise/wiki/How-To:-Use-Recaptcha-with-Devise
      def check_recaptcha
        return if recaptcha_v3_valid?(params[:recaptcha_token], Users::RegistrationsController::RECAPTCHA_V3_ACTION)

        self.resource = build_sign_up_resource # Look for any other validation errors besides reCAPTCHA.
        set_minimum_password_length
        respond_with_navigational(resource) { render :new, status: :unprocessable_content }
      end

      # The sign-up form's user, validated without the password (chosen in step 2) and without the
      # "has already been taken" checks for email and name (see the class comment): the email check
      # would tell anyone whether the address has an account, and the name is checked in step 2.
      def build_sign_up_resource
        user = resource_class.new(sign_up_params.slice(:email, :name))
        user.password = user.password_confirmation = Devise.friendly_token(32)
        user.validate
        user.errors.delete(:email, :taken)
        user.errors.delete(:name, :taken)
        user.password = user.password_confirmation = nil
        user
      end

      def send_sign_up_email user
        existing_user = resource_class.find_for_authentication(email: user.email)

        if existing_user
          SignUpMailer.already_registered(existing_user).deliver_now unless existing_user.deleted?
        else
          token = self.class.sign_up_token(email: user.email, name: user.name)
          SignUpMailer.finish_sign_up(email: user.email, token: token).deliver_now
        end
      end

      def load_sign_up_from_token
        data = self.class.sign_up_verifier.verified(params[:token].to_s, purpose: SIGN_UP_TOKEN_PURPOSE)
        unless data.is_a?(Hash) && data['email'].present?
          redirect_to new_user_registration_path, alert: INVALID_SIGN_UP_LINK_MESSAGE
          return
        end

        if email_registered?(data['email'])
          redirect_to new_user_session_path, alert: ALREADY_REGISTERED_MESSAGE
          return
        end

        @sign_up = { email: data['email'], name: data['name'] }
        @sign_up_token = params[:token]
      end

      def email_registered? email
        resource_class.find_for_authentication(email: email).present?
      end

      def name_taken? name
        name.present? && resource_class.exists?(name: name)
      end

      # A unique index violation means the email or the name was taken after validation (race).
      def save_new_user user
        user.save
      rescue ActiveRecord::RecordNotUnique
        user.errors.add(email_registered?(user.email) ? :email : :name, :taken)
        false
      end
  end
end
