require 'spec_helper'

describe CatalogController do

  it { should use_before_action(:handle_family_not_found) }
  it { should use_before_action(:get_parameters) }

  describe 'GET #show' do
    context "without a family existing in the database" do
      before { get :show }
      it { should render_template('family_not_found') }
    end
  end

end
