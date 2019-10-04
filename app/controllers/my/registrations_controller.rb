module My
  class RegistrationsController < Devise::RegistrationsController
    NEW_CONTRIBUTORS_HELP_PAGE_WIKI_PAGE_ID = 1

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
          params.delete(:password)
          params.delete(:password_confirmation)
          params.delete(:current_password)
        end

        resource.update(params)
      end

      def after_sign_up_path_for _resource
        if (wiki_page = WikiPage.find_by(id: NEW_CONTRIBUTORS_HELP_PAGE_WIKI_PAGE_ID))
          wiki_page_path wiki_page
        else
          root_path
        end
      end

    private

      def check_if_too_many_registrations_today
        return unless User.too_many_registrations_today?
        redirect_to root_path, alert: 'Sorry, we have had too many new registrations today. Email us?'
      end

      def on_spam _options = {}
        redirect_to root_path, alert: "You're not a bot are you? Email us?"
      end
  end
end
