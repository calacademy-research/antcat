# frozen_string_literal: true

# Edits by unconfirmed users, for review.
#
# Routes: GET /activities/unconfirmed (signed in). Purpose, rights and tests of each: docs/catalog/routes.tsv.
module Activities
  class UnconfirmedsController < ApplicationController
    before_action :authenticate_user!

    def show
      @activities = Activity.unconfirmed.includes(:user).paginate(page: params[:page])
    end
  end
end
