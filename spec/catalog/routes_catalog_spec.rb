# frozen_string_literal: true

require 'rails_helper'
require 'csv'

# The function catalog (docs/catalog/routes.csv) has one row per route of the app: who may use it, what it is for,
# whether it stays, and which spec covers it. This spec fails when a route has no row or a row has no route, so a new
# route cannot be added without saying what it is for. Its failure message prints the missing rows, ready to paste.
describe "Function catalog (docs/catalog/routes.csv)" do
  def self.app_routes
    Rails.application.routes.routes.filter_map do |route|
      controller = route.defaults[:controller]
      next if controller.blank? || controller.start_with?("rails/", "active_storage/", "action_mailbox/")

      path = route.path.spec.to_s.delete_suffix("(.:format)")
      verb = route.verb.presence || "ANY"
      { verb: verb, path: path, action: "#{controller}##{route.defaults[:action]}", name: route.name.to_s }
    end.uniq { |r| [r[:verb], r[:path], r[:action]] }
  end

  def self.catalog_rows
    CSV.read(Rails.root.join("docs/catalog/routes.csv"), headers: true).map(&:to_h)
  end

  let(:routes) { self.class.app_routes }
  let(:rows) { self.class.catalog_rows }
  let(:key) { ->(h) { [h[:verb] || h["verb"], h[:path] || h["path"], h[:action] || h["action"]] } }

  it "has a row for every route" do
    have = rows.map(&key).to_set
    missing = routes.reject { |r| have.include?(key.call(r)) }
    lines = missing.map { |r| CSV.generate_line([r[:verb], r[:path], r[:action], r[:name], "", "", "", ""]) }
    expect(missing).to be_empty, "#{missing.size} routes have no row in docs/catalog/routes.csv:\n#{lines.join}"
  end

  it "has a route for every row" do
    have = routes.map(&key).to_set
    stale = rows.reject { |r| have.include?(key.call(r)) }
    expect(stale).to be_empty, "rows with no route (removed or renamed): #{stale.map { |r| key.call(r).join(' ') }}"
  end

  it "says for every row who may use it, what it is for and whether it stays" do
    blank = rows.select { |r| r["who"].blank? || r["purpose"].blank? || r["status"].blank? }
    expect(blank).to be_empty, "#{blank.size} rows without who, purpose or status: #{blank.first(5).map { |r| r['path'] }}"
  end

  it "uses the known values for who and status" do
    expect(rows.map { |r| r["who"] }.uniq - %w[public user editor helper admin superadmin api system]).to be_empty
    expect(rows.map { |r| r["status"] }.uniq - %w[keep check remove]).to be_empty
  end
end
