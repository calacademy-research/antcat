require 'spec_helper'

describe FeedbackController do
  render_views

  it { is_expected.to have_valid_where_filters }
end
