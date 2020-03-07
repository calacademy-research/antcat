class ApplicationController < ActionController::Base
  NotAuthorized = Class.new(StandardError)

  protect_from_forgery with: :exception

  before_action :save_location
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_paper_trail_whodunnit, :set_current_request_uuid

  before_action :cors_preflight_check
  after_action :cors_set_access_control_headers

  delegate :editor?, :at_least_helper?, :superadmin?, to: :current_user, prefix: 'user_is', allow_nil: true
  helper_method :user_is_editor?, :user_is_at_least_helper?, :user_is_superadmin?

  rescue_from NotAuthorized do |exception|
    render plain: "You need the '#{exception.message}' permission to do that :(", status: :forbidden
  end

  # :nocov:
  if Rails.env.development?
    rescue_from RSolr::Error::ConnectionRefused do
      render plain: "Start Solr: `bundle exec rake sunspot:solr:start RAILS_ENV=development`"
    end
  end
  # :nocov:

  def user_for_paper_trail
    current_user&.id
  end

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :name, :password, :password_confirmation])
      devise_parameter_sanitizer.permit(:sign_in, keys: [:email, :password, :remember_me])
      devise_parameter_sanitizer.permit(:account_update, keys: [:email, :name, :password, :password_confirmation, :current_password])
    end

  private

    # Save location to redirect back to after signing in.
    def save_location
      return if request.xhr? || request.url =~ %r{/users/}
      session[:user_return_to] = request.url
    end

    def cors_set_access_control_headers
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'GET'
      headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token'
      headers['Access-Control-Max-Age'] = "1728000"
    end

    def cors_preflight_check
      return unless request.method == 'OPTIONS'

      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
      headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version, Token'
      headers['Access-Control-Max-Age'] = '1728000'

      render plain: ''
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
      raise NotAuthorized, "editor" unless user_is_editor?
    end

    def ensure_user_is_at_least_helper
      authenticate_user!
      raise NotAuthorized, "helper" unless user_is_at_least_helper?
    end

    def ensure_user_is_superadmin
      authenticate_user!
      raise NotAuthorized, "superadmin" unless user_is_superadmin?
    end
end
