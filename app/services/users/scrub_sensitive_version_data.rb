# frozen_string_literal: true

# Removes `User::SKIP_PAPER_TRAIL_COLUMNS` (password hashes, reset/remember tokens, sign-in data)
# from `object` and `object_changes` of existing `User` versions. One-off cleanup for versions
# created before `has_paper_trail skip:` was used; run via `rake antcat:users:scrub_sensitive_version_data`.
module Users
  class ScrubSensitiveVersionData
    include Service

    COLUMNS = %w[object object_changes].freeze

    attr_private_initialize [{ dry_run: true }]

    # Returns counts: versions checked, versions with sensitive keys, and keys removed per column.
    def call
      counts = { checked: 0, affected: 0, removed_keys: Hash.new(0) }

      PaperTrail::Version.where(item_type: 'User').find_each do |version|
        counts[:checked] += 1
        changes = scrubbed_columns(version, counts[:removed_keys])
        next if changes.empty?

        counts[:affected] += 1
        version.update_columns(changes) unless dry_run # rubocop:disable Rails/SkipsModelValidations
      end

      counts
    end

    private

      def sensitive_keys
        @_sensitive_keys ||= User::SKIP_PAPER_TRAIL_COLUMNS.map(&:to_s)
      end

      def scrubbed_columns version, removed_keys
        COLUMNS.each_with_object({}) do |column, changes|
          serialized = version.read_attribute(column)
          next if serialized.blank?

          data = PaperTrail.serializer.load(serialized)
          next unless data.is_a?(Hash)

          keys = data.keys.map(&:to_s) & sensitive_keys
          next if keys.empty?

          keys.each { |key| removed_keys[key] += 1 }
          changes[column] = PaperTrail.serializer.dump(data.except(*keys, *keys.map(&:to_sym)))
        end
      end
  end
end
