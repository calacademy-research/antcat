require 'spec_helper'

describe Catalog::SearchController do
  describe "GET index" do
    context 'when not searching yet' do
      context 'when just visiting the page' do
        it 'renders the search form' do
          get :index, params: { searching_from_header: 'y', submit_search: 'y', qq: '' }
          expect(response).to render_template 'index'
          expect(assigns(:taxa)).to eq nil
        end
      end

      context 'when searching for nothing from the header' do
        it 'renders the search form' do
          get :index
          expect(response).to render_template 'index'
          expect(assigns(:taxa)).to eq nil
        end
      end
    end

    context 'when there is a single exact match' do
      let!(:exact_match) { create :species, name_string: 'Lasius niger' }

      context 'when searching from the header' do
        it 'redirects to the match' do
          get :index, params: { searching_from_header: 'y', submit_search: 'y', qq: 'Lasius niger' }
          expect(response).to redirect_to catalog_path(exact_match, qq: 'Lasius niger')
        end
      end

      context 'when following links from AntWeb' do
        it 'redirects to the match' do
          get :index, params: { st: 'y', submit_search: 'y', qq: 'Lasius niger' }
          expect(response).to redirect_to catalog_path(exact_match, qq: 'Lasius niger')
        end
      end

      context 'when searching from the search form' do
        it 'shows the results' do
          get :index, params: { submit_search: 'y', qq: 'Lasius niger' }
          expect(response).to_not redirect_to catalog_path(exact_match, qq: 'Lasius niger')
          expect(response).to render_template 'index'
          expect(assigns(:taxa)).to eq [exact_match]
        end
      end
    end

    context 'when searching for an author name that does not exist' do
      it 'shows a warning message' do
        get :index, params: { submit_search: 'y', author_name: 'Pizza Man' }
        expect(response.request.flash[:alert]).
          to eq "If you're choosing an author, make sure you pick the name from the dropdown list."
      end
    end
  end
end
