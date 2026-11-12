# frozen_string_literal: true

# Free registered API keys for `/v1` and the usage counts behind the limits (see `ApiAccess`).
#
# - `api_keys`: one row per registration. The key itself is never stored, only its SHA-256 digest
#   and a short prefix for display; the confirmation link's token is also stored only as a digest.
# - `api_usage_days`: requests, records and refused requests (429) per day, per key. Requests without
#   a key have `api_key_id` 0 and a hash of the visitor's IP made with a salt that changes every day
#   (`client`); raw IPs are never stored.
# - `api_usage_minutes`: requests per minute for the per-minute limit; rows older than a few minutes
#   are deleted as new ones come in. In the database (not `Rails.cache`), so both Puma workers share them.
class CreateApiKeysAndUsage < ActiveRecord::Migration[8.1]
  def up
    create_table :api_keys, charset: "utf8mb4", collation: "utf8mb4_unicode_ci" do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :institution
      t.text :project, null: false
      t.string :level, null: false, default: "registered"
      t.string :status, null: false, default: "pending"
      t.string :key_digest, limit: 64
      t.string :key_prefix, limit: 16
      t.string :confirmation_digest, limit: 64
      t.datetime :confirmation_sent_at
      t.datetime :terms_accepted_at, null: false
      t.datetime :confirmed_at
      t.datetime :revoked_at
      t.datetime :last_used_at
      t.integer :requests_per_minute
      t.integer :requests_per_day
      t.integer :records_per_page
      t.integer :records_per_day
      t.text :note
      t.timestamps
    end
    add_index :api_keys, :confirmation_digest, unique: true, name: "ux_api_keys__confirmation_digest"
    add_index :api_keys, :email, name: "ix_api_keys__email"
    add_index :api_keys, :key_digest, unique: true, name: "ux_api_keys__key_digest"

    # Counter table, written only by `INSERT ... ON DUPLICATE KEY UPDATE`; the date/minute column is the time.
    create_table :api_usage_days, charset: "utf8mb4", collation: "utf8mb4_unicode_ci" do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.date :day, null: false
      t.bigint :api_key_id, null: false, default: 0
      t.string :client, limit: 64, null: false, default: ""
      t.integer :requests, null: false, default: 0
      t.integer :records, null: false, default: 0
      t.integer :rejected, null: false, default: 0
    end
    add_index :api_usage_days, [:api_key_id, :day], name: "ix_api_usage_days__api_key_id__day"
    add_index :api_usage_days, [:day, :api_key_id, :client], unique: true, name: "ux_api_usage_days__day__api_key_id__client"

    # Counter table, written only by `INSERT ... ON DUPLICATE KEY UPDATE`; the date/minute column is the time.
    create_table :api_usage_minutes, charset: "utf8mb4", collation: "utf8mb4_unicode_ci" do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.datetime :minute, null: false
      t.bigint :api_key_id, null: false, default: 0
      t.string :client, limit: 64, null: false, default: ""
      t.integer :requests, null: false, default: 0
    end
    add_index :api_usage_minutes, [:minute, :api_key_id, :client], unique: true,
      name: "ux_api_usage_minutes__minute__api_key_id__client"
  end

  def down
    drop_table :api_usage_minutes
    drop_table :api_usage_days
    drop_table :api_keys
  end
end
