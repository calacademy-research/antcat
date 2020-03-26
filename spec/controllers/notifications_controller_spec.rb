# frozen_string_literal: true

require 'rails_helper'

describe NotificationsController do
  describe "forbidden actions" do
    context "when not signed in", as: :visitor do
      specify { expect(get(:index)).to redirect_to_signin_form }
    end
  end
end
