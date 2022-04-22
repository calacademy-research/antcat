# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include HttpBasicAuth

  NotAuthorized = Class.new(StandardError)

  protect_from_forgery with: :exception

  before_action :set_new_relic_custom_attributes
  before_action :store_location_for_devise, if: :storable_location?
  before_action :set_paper_trail_whodunnit, :set_current_request_uuid

  delegate :editor?, :at_least_helper?, :superadmin?, :developer?, to: :current_user, prefix: 'user_is', allow_nil: true
  helper_method :user_is_editor?, :user_is_at_least_helper?, :user_is_superadmin?, :user_is_developer?

  rescue_from NotAuthorized do |exception|
    render plain: "You need the '#{exception.message}' permission to do that :(", status: :forbidden
  end

  # :nocov:
  if Rails.env.development?
    rescue_from RSolr::Error::ConnectionRefused do
      render plain: "Start Solr: `RAILS_ENV=development bundle exec rake sunspot:solr:start`"
    end
  end
  # :nocov:

  def user_for_paper_trail
    current_user&.id
  end

  private

    def storable_location?
      request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
    end

    # See https://github.com/heartcombo/devise/wiki/How-To:-Redirect-back-to-current-page-after-sign-in,-sign-out,-sign-up,-update
    def store_location_for_devise
      store_location_for(:user, request.fullpath)
    end

    def set_current_request_uuid
      RequestStore.store[:current_request_uuid] = SecureRandom.uuid
    end

    def ensure_unconfirmed_user_is_not_over_edit_limit
      authenticate_user!
      redirect_to editors_panel_path, alert: <<~MSG if current_user.unconfirmed_user_over_edit_limit?
        You have reached your allowed number of edits for today, please come back tomorrow!'
      MSG
    end

    def ensure_user_is_editor
      authenticate_user!
      raise NotAuthorized, User::EDITOR unless user_is_editor?
    end

    def ensure_user_is_at_least_helper
      authenticate_user!
      raise NotAuthorized, User::HELPER unless user_is_at_least_helper?
    end

    def ensure_user_is_superadmin
      authenticate_user!
      raise NotAuthorized, User::SUPERADMIN unless user_is_superadmin?
    end

    def ensure_user_is_developer
      authenticate_user!
      raise NotAuthorized, User::DEVELOPER unless user_is_developer?
    end

    def set_new_relic_custom_attributes
      if current_user
        ::NewRelic::Agent.add_custom_attributes(
          user_email: current_user.email,
          user_id: current_user.id
        )
      end
    end

    def recaptcha_v3_valid? token, recaptcha_action
      return true unless Settings.recaptcha.enabled
      return true if current_user
      VerifyRecaptchaV3[token, recaptcha_action]
    end
end
