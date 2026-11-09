# frozen_string_literal: true

# Registration for free AntCat API keys (see `ApiAccess` and `ApiKey`). No site account is needed.
#
# 1. `new` / `create`: name, email, project (required), institution (optional), "I agree to the terms",
#    reCAPTCHA. Throttled per IP and per email (`RequestThrottle`). Saves a pending registration and
#    emails a confirmation link. The email has only the link: the typed name and project are not put
#    in it, so the form cannot be used to send someone else's text from antcat.org.
# 2. `confirm` (the emailed link, GET): a page with a button. The key is not made on GET, so a mail
#    scanner that opens links does not use up the link.
# 3. `issue` (the button, POST): makes the key and shows it once; emails a copy of the registration
#    (without the key) to `Settings.api_keys.registration_copy_to`.
#
# Answers 404 while `Settings.api_keys.enabled` is off.
class ApiKeysController < ApplicationController
  include RequestThrottle

  RECAPTCHA_V3_ACTION = 'api_key'
  REGISTRATIONS_PER_IP = 5
  REGISTRATIONS_PER_EMAIL = 3
  REGISTRATIONS_WITHIN = 1.hour
  TOO_MANY_REGISTRATIONS_MESSAGE = "Too many registrations. Please wait a while and try again."
  RECAPTCHA_FAILED_MESSAGE = "The check that you are not a robot failed. Please try again."
  EMAIL_SENT_MESSAGE = "Thank you. We have sent you an email with a link. Open it within " \
                       "#{(ApiKey::CONFIRMATION_VALID_FOR / 1.hour).to_i} hours to get your API key.".freeze
  INVALID_LINK_MESSAGE = "This link is not valid: it has expired or was already used. Please register again."

  before_action :ensure_api_keys_enabled
  before_action :throttle_registration, only: :create
  skip_before_action :store_location_for_devise

  def new
    @api_key = ApiKey.new
  end

  def create
    @api_key = ApiKey.new(registration_params)

    unless recaptcha_v3_valid?(params[:recaptcha_token], RECAPTCHA_V3_ACTION)
      flash.now[:alert] = RECAPTCHA_FAILED_MESSAGE
      return render :new, status: :unprocessable_content
    end

    token = @api_key.new_confirmation_token
    if @api_key.save
      ApiKeyMailer.confirm_email(@api_key, token).deliver_now
      redirect_to new_api_key_path, notice: EMAIL_SENT_MESSAGE
    else
      render :new, status: :unprocessable_content
    end
  end

  def confirm
    @token = params[:token].to_s
    redirect_to new_api_key_path, alert: INVALID_LINK_MESSAGE unless ApiKey.find_pending_by_confirmation_token(@token)
  end

  def issue
    api_key = ApiKey.find_pending_by_confirmation_token(params[:token])
    @key = api_key&.issue_key!
    return redirect_to new_api_key_path, alert: INVALID_LINK_MESSAGE unless @key

    send_registration_copy api_key
    @api_key = api_key
    no_store # The page shows the key; browsers and proxies must not keep it.
    render :issued
  end

  private

    def ensure_api_keys_enabled
      raise ActionController::RoutingError, 'Not Found' unless ApiAccess.enabled?
    end

    def registration_params
      params.expect(api_key: [:name, :email, :institution, :project, :terms])
    end

    # The key is already issued and only shown on this page, so a mail problem must not stop the page.
    def send_registration_copy api_key
      ApiKeyMailer.registration_copy(api_key).deliver_now
    rescue StandardError => e
      Rails.logger.error "API key ##{api_key.id}: registration copy not sent (#{e.class})"
    end

    def throttle_registration
      throttled = request_throttled?(
        "api_key",
        per_ip: REGISTRATIONS_PER_IP, per_email: REGISTRATIONS_PER_EMAIL,
        within: REGISTRATIONS_WITHIN, email: params.dig(:api_key, :email)
      )
      redirect_to new_api_key_path, alert: TOO_MANY_REGISTRATIONS_MESSAGE if throttled
    end
end
