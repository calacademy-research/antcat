# frozen_string_literal: true

require 'rails_helper'

# A fresh setup (empty MySQL data directory) creates the app's own MySQL account from dockerized_app/.env, the same
# values the app connects with. The values come from the environment; no password is kept in the repo.
describe "dockerized_app db service" do
  let(:compose) { YAML.safe_load_file(Rails.root.join('dockerized_app/docker-compose.yml')) }
  let(:db_environment) { compose['services']['db']['environment'] }
  let(:app_environment) { compose['services']['app']['environment'] }

  it "creates the app's database and account on first start, from the app's .env values" do
    expect(db_environment).to include('MYSQL_DATABASE=antcat')
    expect(db_environment).to include(a_string_starting_with('MYSQL_USER=${ANTCAT_APP_DB_USER:?'))
    expect(db_environment).to include(a_string_starting_with('MYSQL_PASSWORD=${ANTCAT_APP_DB_PASSWORD:?'))

    expect(app_environment['DB_DATABASE']).to eq 'antcat'
    expect(app_environment['DB_USERNAME']).to start_with('${ANTCAT_APP_DB_USER:?')
    expect(app_environment['DB_PASSWORD']).to start_with('${ANTCAT_APP_DB_PASSWORD:?')
  end
end
