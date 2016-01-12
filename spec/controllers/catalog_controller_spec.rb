require 'spec_helper'

describe CatalogController do

  it { should use_before_action(:handle_family_not_found) }
  it { should use_before_action(:get_parameters) }

  describe 'GET #show' do
    describe "handle non-existing family" do
      context "family exists" do
        before do
          FactoryGirl.create(:family)
          get :show
        end
        it { should render_template('show') }
      end
      context "without a family existing in the database" do
        before { get :show }
        it { should render_template('family_not_found') }
      end
    end
  end

  describe "show an hide" do
    before { FactoryGirl.create(:family) }

    describe "tribes" do
      describe 'GET #show_tribes' do
        before { get :show_tribes }
        it { should set_session[:show_tribes].to(true) }
      end
      describe 'GET #hide_tribes' do
        before { get :hide_tribes }
        it { should set_session[:show_tribes].to(false) }
        # TODO take into account (in test) if the linked was clicked from a tribe page
      end
    end

    describe "unavailable subfamilies" do
      describe 'GET #show_unavailable_subfamilies' do
        before { get :show_unavailable_subfamilies }
        it { should set_session[:show_unavailable_subfamilies].to(true) }
      end
      describe 'GET #hide_unavailable_subfamilies' do
        before { get :hide_unavailable_subfamilies }
        it { should set_session[:show_unavailable_subfamilies].to(false) }
      end
    end

    describe "subgenera" do
      describe 'GET #show_subgenera' do
        before { get :show_subgenera }
        it { should set_session[:show_subgenera].to(true) }
      end
      describe 'GET #hide_subgenera' do
        before { get :hide_subgenera }
        it { should set_session[:show_subgenera].to(false) }
        # TODO take into account (in test) if the linked was clicked from a subgenus page
      end
    end
  end

end
