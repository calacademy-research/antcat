# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include HttpBasicAuth

  class NotAuthorized < StandardError
  end

  protect_from_forgery with: :exception

  before_action :set_new_relic_custom_attributes
  before_action :store_location_for_devise, if: :storable_location?
  before_action :set_paper_trail_whodunnit, :set_current_request_uuid

  # Visitors who are not signed in get smaller result pages and exports, since large pages and
  # REGEXP searches are expensive (full table scans on a small server).
  MAX_PER_PAGE_FOR_VISITORS = 100
  MAX_EXPORT_RECORDS_FOR_VISITORS = 500
  TOO_LARGE_EXPORT_MESSAGE = "Exports of more than #{MAX_EXPORT_RECORDS_FOR_VISITORS} records are available to signed-in users. Please sign in or narrow the search."

  delegate :editor?, :at_least_helper?, :superadmin?, :developer?, to: :current_user, prefix: 'user_is', allow_nil: true
  helper_method :user_is_editor?, :user_is_at_least_helper?, :user_is_superadmin?, :user_is_developer?
  helper_method :per_page_options_for_current_user, :regexp_search_allowed?

  # Bots ask for HTML-only pages as JSON or XML (e.g. `/` with `Accept: application/json`).
  # Answer "406 Not Acceptable" instead of a 500 from the missing template.
  rescue_from ActionView::MissingTemplate do |exception|
    raise exception if request.format.html?
    head :not_acceptable
  end

  rescue_from NotAuthorized do |exception|
    render plain: "You need the '#{exception.message}' permission to do that :(", status: :forbidden
  end

  # :nocov:
  if Rails.env.development?
    rescue_from RSolr::Error::ConnectionRefused do
      render plain: "Start Solr: \nRAILS_ENV=development bundle exec rake sunspot:solr:start"
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

    def per_page_options_for_current_user options
      return options if current_user
      options.select { |option| option <= MAX_PER_PAGE_FOR_VISITORS }
    end

    # `params[:per_page]` capped by the largest allowed option; the smallest option when missing or invalid.
    def per_page_from_params options
      allowed = per_page_options_for_current_user(options)
      requested = params[:per_page].to_i
      requested.between?(1, allowed.max) ? requested : allowed.min
    end

    def regexp_search_allowed?
      current_user.present?
    end

    # For `before_action`: REGEXP searches need a signed-in user.
    def ensure_regexp_search_allowed
      authenticate_user! if params[:search_type] == 'REGEXP' && !regexp_search_allowed?
    end

    def recaptcha_v3_valid? token, recaptcha_action
      return true unless Settings.recaptcha.enabled
      return true if current_user

      VerifyRecaptchaV3[token, recaptcha_action]
    end
end
