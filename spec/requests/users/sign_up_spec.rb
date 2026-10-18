# frozen_string_literal: true

require 'rails_helper'

describe "Signing up" do
  let(:deliveries) { ActionMailer::Base.deliveries }
  let(:new_email) { 'pizza@example.com' }
  let(:password) { 'secret123-password' }

  before { deliveries.clear }

  def sign_up email:, name: 'Quintus Batiatus'
    post user_registration_path, params: { user: { email: email, name: name } }
  end

  def link_from_last_email
    deliveries.last.body.decoded[%r{http://antcat\.local(/users/sign_up/complete\?token=[^"\s]+)}, 1].
      then { |path| CGI.unescapeHTML(path) }
  end

  def token_from path
    Rack::Utils.parse_query(URI.parse(path).query)['token']
  end

  describe "POST /users (sign-up form)" do
    let!(:existing_user) { create :user, email: 'existing@example.com', name: 'Existing User' }

    it "responds the same whether or not the email has an account" do
      sign_up email: new_email
      new_email_response = [response.status, response.location, flash[:notice]]

      sign_up email: 'existing@example.com'
      existing_email_response = [response.status, response.location, flash[:notice]]

      expect(new_email_response).to eq existing_email_response
      expect(new_email_response).to eq [302, root_url, Users::RegistrationsController::SIGN_UP_EMAIL_SENT_MESSAGE]
    end

    it "treats the email case-insensitively" do
      sign_up email: 'EXISTING@example.com'

      expect(response).to redirect_to root_path
      expect(deliveries.last.subject).to eq 'You already have an account - antcat.org'
    end

    it "does not create a user before the emailed link is used" do
      expect { sign_up email: new_email }.not_to change { User.count }
      expect { sign_up email: 'existing@example.com' }.not_to change { User.count }
    end

    it "emails a sign-up link to a new address" do
      expect { sign_up email: new_email }.to change { deliveries.count }.by(1)

      mail = deliveries.last
      expect(mail.to).to eq [new_email]
      expect(mail.subject).to eq 'Finish signing up - antcat.org'
      expect(link_from_last_email).to be_present
    end

    it "emails a notice (and no sign-up link) to an address that has an account" do
      expect { sign_up email: 'existing@example.com' }.to change { deliveries.count }.by(1)

      mail = deliveries.last
      expect(mail.to).to eq ['existing@example.com']
      expect(mail.subject).to eq 'You already have an account - antcat.org'
      expect(mail.body.decoded).not_to include 'sign_up/complete'
      expect(mail.body.decoded).to include '/users/password/new'
    end

    it "does not email deleted accounts" do
      existing_user.update_columns(deleted: true)

      expect { sign_up email: 'existing@example.com' }.not_to change { deliveries.count }
      expect(response).to redirect_to root_path
    end

    it "does not mention that an email is taken when the form has other errors" do
      sign_up email: 'existing@example.com', name: ''
      existing_email_body = response.body

      expect(response).to have_http_status :unprocessable_content
      expect(existing_email_body).to match(/Name can(&#39;|')t be blank/)
      expect(existing_email_body).not_to include "Email has already been taken"
      expect(deliveries).to be_empty

      sign_up email: new_email, name: ''
      expect(response).to have_http_status :unprocessable_content
      expect(response.body).to match(/Name can(&#39;|')t be blank/)
    end

    # Regression: someone with an account who signs up again with their own name got
    # "Name has already been taken" and no email.
    it "emails the notice to an address that has an account, even if the name is taken" do
      create :user, name: 'Someone Else'

      ['Existing User', 'Someone Else'].each do |taken_name|
        deliveries.clear
        sign_up email: 'existing@example.com', name: taken_name

        expect(response).to redirect_to root_path
        expect(flash[:notice]).to eq Users::RegistrationsController::SIGN_UP_EMAIL_SENT_MESSAGE
        expect(deliveries.map(&:subject)).to eq ['You already have an account - antcat.org']
      end
    end

    it "does not check whether the name is taken (the same response for registered and new addresses)" do
      sign_up email: new_email, name: 'Existing User'

      expect(response).to redirect_to root_path
      expect(flash[:notice]).to eq Users::RegistrationsController::SIGN_UP_EMAIL_SENT_MESSAGE
      expect(deliveries.last.subject).to eq 'Finish signing up - antcat.org'
    end

    it "still validates the email format" do
      sign_up email: 'not-an-email'

      expect(response).to have_http_status :unprocessable_content
      expect(response.body).to include "Email is invalid"
      expect(deliveries).to be_empty
    end

    it "ignores unpermitted attributes" do
      post user_registration_path, params: { user: { email: new_email, name: 'Quintus Batiatus', editor: true } }
      path = link_from_last_email
      post complete_user_sign_up_path, params: {
        token: token_from(path), user: { password: password, password_confirmation: password, superadmin: true }
      }

      user = User.find_by!(email: new_email)
      expect(user.editor).to eq false
      expect(user.superadmin).to eq false
      expect(user.helper).to eq false
    end
  end

  describe "finishing sign-up from the emailed link" do
    before { sign_up email: new_email }

    let(:path) { link_from_last_email }
    let(:token) { token_from(path) }

    it "shows the password form" do
      get path

      expect(response).to have_http_status :ok
      expect(response.body).to include new_email
      expect(response.body).to include 'Quintus Batiatus'
      expect(response.body).to include 'Finish Signing Up'
    end

    it "creates the account, signs in and records an activity" do
      expect do
        post complete_user_sign_up_path,
          params: { token: token, user: { password: password, password_confirmation: password } }
      end.to change { User.count }.by(1).and change { Activity.where(event: Activity::CREATE).count }.by(1)

      user = User.last
      expect(user.email).to eq new_email
      expect(user.name).to eq 'Quintus Batiatus'
      expect(user.valid_password?(password)).to eq true
      expect(Activity.last.parameters).to eq(user_id: user.id)
      expect(response).to redirect_to root_path
      expect(flash[:notice]).to eq "Welcome! You have signed up successfully."
      expect(controller.current_user).to eq user
    end

    context "when the New contributors' help page exists" do
      let!(:wiki_page) { create :wiki_page, :new_contributors_help_page }

      it "redirects to it" do
        post complete_user_sign_up_path,
          params: { token: token, user: { password: password, password_confirmation: password } }

        expect(response).to redirect_to "/wiki/#{wiki_page.id}"
      end
    end

    it "lets the person change the name" do
      post complete_user_sign_up_path,
        params: { token: token, user: { name: 'Q. Batiatus', password: password, password_confirmation: password } }

      expect(User.last.name).to eq 'Q. Batiatus'
    end

    it "ignores an email in the form (the address comes from the link)" do
      post complete_user_sign_up_path,
        params: { token: token, user: { email: 'other@example.com', password: password, password_confirmation: password } }

      expect(User.last.email).to eq new_email
    end

    context "when the name was taken before the link is used" do
      before { create :user, name: 'Quintus Batiatus' }

      it "shows the error on the password form" do
        get path

        expect(response).to have_http_status :ok
        expect(response.body).to include "Name has already been taken"
      end

      it "does not create the account with that name, and accepts another name" do
        expect do
          post complete_user_sign_up_path,
            params: { token: token, user: { password: password, password_confirmation: password } }
        end.not_to change { User.count }
        expect(response).to have_http_status :unprocessable_content
        expect(response.body).to include "Name has already been taken"

        post complete_user_sign_up_path,
          params: { token: token, user: { name: 'Q. Batiatus', password: password, password_confirmation: password } }
        expect(User.find_by!(email: new_email).name).to eq 'Q. Batiatus'
      end
    end

    it "shows an error (not a crash) when the name is taken at the moment of saving" do
      allow(User).to receive(:new).and_wrap_original do |original, *args|
        original.call(*args).tap do |user|
          allow(user).to receive(:save).and_raise(ActiveRecord::RecordNotUnique)
        end
      end

      post complete_user_sign_up_path,
        params: { token: token, user: { password: password, password_confirmation: password } }

      expect(response).to have_http_status :unprocessable_content
      expect(response.body).to include "Name has already been taken"
    end

    it "requires a valid password" do
      expect do
        post complete_user_sign_up_path,
          params: { token: token, user: { password: 'short', password_confirmation: 'short' } }
      end.not_to change { User.count }

      expect(response).to have_http_status :unprocessable_content
      expect(response.body).to include 'Password is too short'
    end

    it "works only once" do
      post complete_user_sign_up_path,
        params: { token: token, user: { password: password, password_confirmation: password } }
      delete destroy_user_session_path

      expect do
        post complete_user_sign_up_path,
          params: { token: token, user: { password: 'another-password-2', password_confirmation: 'another-password-2' } }
      end.not_to change { User.count }
      expect(response).to redirect_to new_user_session_path
      expect(User.last.valid_password?(password)).to eq true
    end

    it "rejects a tampered token" do
      get complete_user_sign_up_path(token: "#{token}x")
      expect(response).to redirect_to new_user_registration_path

      expect do
        post complete_user_sign_up_path,
          params: { token: "#{token}x", user: { password: password, password_confirmation: password } }
      end.not_to change { User.count }
      expect(response).to redirect_to new_user_registration_path
    end

    it "rejects an expired token" do
      token # Generate the link now.

      expired_at = Users::RegistrationsController::SIGN_UP_LINK_VALID_FOR.from_now + 1.minute
      travel_to expired_at do
        get complete_user_sign_up_path(token: token)
        expect(response).to redirect_to new_user_registration_path
        expect(flash[:alert]).to eq Users::RegistrationsController::INVALID_SIGN_UP_LINK_MESSAGE
      end
    end

    it "rejects a token made for another purpose" do
      other_token = Users::RegistrationsController.sign_up_verifier.generate(
        { 'email' => 'mallory@example.com', 'name' => 'Mallory' }, purpose: :something_else
      )

      get complete_user_sign_up_path(token: other_token)
      expect(response).to redirect_to new_user_registration_path
    end
  end
end
