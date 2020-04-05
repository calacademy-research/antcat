# frozen_string_literal: true

require 'rails_helper'

describe UserMailer do
  describe '#new_notification' do
    let(:user) { create :user }
    let(:notification) { create :notification, user: user }
    let(:mail) { described_class.new_notification(user, notification).deliver_now }

    context 'when user has not disabled email notifications' do
      it 'sends the mail' do
        expect { mail }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      specify do
        expect(mail.subject).to eq "New notification - antcat.org"
        expect(mail.to).to eq [user.email]
      end

      it 'includes the name of the notifier' do
        expect(mail.body.encoded).to include notification.notifier.name
      end

      context 'when notification is a "active_in_discussion"' do
        let(:notification) { create :notification, :active_in_discussion, user: user }
        let(:issue) { notification.attached.commentable }

        it 'includes the reason for notification' do
          expect(mail.body.encoded).to include "commented on the"
          expect(mail.body.encoded).
            to match(%r{issue <a href="http://antcat.local/issues/#{issue.id}">#{issue.title}</a>})
          expect(mail.body.encoded).to include "which you also have commented on"
        end
      end

      context 'when notification is a "mentioned_in_thing"' do
        let(:site_notice) { create :site_notice }
        let(:notification) { create :notification, :mentioned_in_thing, user: user, attached: site_notice }

        it 'includes the reason for the notification' do
          expect(mail.body.encoded).to include "mentioned you in the"
          expect(mail.body.encoded).
            to match(%r{site notice <a href="http://antcat.local/site_notices/#{site_notice.id}">#{site_notice.title}</a>})
        end
      end
    end

    context 'when user has disabled email notifications' do
      let(:user) { create :user, :disabled_email_notifications }

      it 'does not send the mail' do
        expect { mail }.to_not change { ActionMailer::Base.deliveries.count }
      end
    end
  end
end
