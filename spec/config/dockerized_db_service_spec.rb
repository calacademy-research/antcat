# frozen_string_literal: true

require 'rails_helper'
require 'open3'

# A fresh setup (empty MySQL data directory) creates the app's own MySQL account from dockerized_app/.env, the same
# values the app connects with. The values come from the environment; no password is kept in the repo.
describe "dockerized_app db service" do # rubocop:disable RSpec/DescribeClass
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

  # MySQL creates the database and the app's account before it loads mysql84-init, so the init SQL must not stop
  # at a CREATE DATABASE or CREATE USER of the dump.
  describe "setup_db.sh" do
    let(:dir) { Dir.mktmpdir }
    let(:dump) { File.join(dir, 'dump.sql') }
    let(:init_sql) { File.read(File.join(dir, 'mysql84-init/1-init.sql')) }

    before do
      FileUtils.cp(Rails.root.join('dockerized_app/setup_db.sh'), dir)
      FileUtils.cp_r(Rails.root.join('dockerized_app/mysql84'), dir)
      File.write(dump, <<~SQL)
        CREATE DATABASE antcat;
        CREATE DATABASE /*!32312 IF NOT EXISTS*/ `antcat`;
        CREATE USER 'app'@'%' IDENTIFIED BY 'x';
        CREATE TABLE journals (id int);
      SQL
    end

    after { FileUtils.remove_entry(dir) }

    it "writes init SQL that does not fail on an existing database or account" do
      _output, status = Open3.capture2e('bash', File.join(dir, 'setup_db.sh'), dump)
      expect(status.success?).to eq true

      expect(init_sql.lines.map(&:chomp)).to eq [
        "CREATE DATABASE IF NOT EXISTS antcat;",
        "USE antcat;",
        "CREATE DATABASE IF NOT EXISTS antcat;",
        "CREATE DATABASE /*!32312 IF NOT EXISTS*/ `antcat`;",
        "CREATE USER IF NOT EXISTS 'app'@'%' IDENTIFIED BY 'x';",
        "CREATE TABLE journals (id int);"
      ]
      expect(File.exist?(File.join(dir, 'mysql84-init/00-root-native-password.sh'))).to eq true
    end

    it "changes nothing when the dump is missing" do
      _output, status = Open3.capture2e('bash', File.join(dir, 'setup_db.sh'), File.join(dir, 'missing.sql'))
      expect(status.success?).to eq false
      expect(Dir.exist?(File.join(dir, 'mysql84-init'))).to eq false
    end
  end
end
