# frozen_string_literal: true

module RecaptchaHelper
  RECAPTCHA_V3_SITE_KEY = Settings.recaptcha.v3.site_key

  def include_recaptcha_v3_js
    return unless Settings.recaptcha.enabled
    return if current_user

    content_for :javascripts do
      raw %(<script src="https://www.google.com/recaptcha/api.js?render=#{RECAPTCHA_V3_SITE_KEY}"></script>)
    end
  end

  def recaptcha_v3_execute action
    return unless Settings.recaptcha.enabled
    return if current_user

    id = "recaptcha_token_#{SecureRandom.hex(10)}"

    raw %(
      <input name="recaptcha_token" type="hidden" id="#{id}"/>
      <script>
        grecaptcha.ready(function() {
          grecaptcha.execute('#{RECAPTCHA_V3_SITE_KEY}', { action: '#{action}' }).then(function(token) {
            document.getElementById("#{id}").value = token;
          console.log(token);
          console.log('aaaaaaa');
          });
        });
      </script>
    )
  end
end
