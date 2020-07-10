# frozen_string_literal: true

require 'rails_helper'

describe NotificationDecorator do
  subject(:decorated) { notification.decorate }

  describe "#link_attached" do
    let(:notification) { build_stubbed :notification, attached: attached }

    context "when `attached` is an `Issue`" do
      let(:attached) { build_stubbed :issue }

      specify { expect(decorated.link_attached).to eq %(issue <a href="/issues/#{attached.id}">#{attached.title}</a>) }
    end

    context "when `attached` is a `SiteNotice`" do
      let(:attached) { build_stubbed :site_notice }

      specify { expect(decorated.link_attached).to eq %(site notice <a href="/site_notices/#{attached.id}">#{attached.title}</a>) }
    end

    context "when `attached` is a `Feedback`" do
      let(:attached) { build_stubbed :feedback }

      specify { expect(decorated.link_attached).to eq %(feedback <a href="/feedbacks/#{attached.id}">##{attached.id}</a>) }
    end
  end
end
