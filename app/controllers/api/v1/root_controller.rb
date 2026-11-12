# frozen_string_literal: true

# The front door of the AntCat API (`GET /v1`): what the API is, its terms of use, the licence, how to cite and
# where the documentation is. Programs and AI agents read it before they send requests; it is also the address
# Cloudflare lets through without a challenge (only `/v1/` paths are), so it carries the same guidance as
# `/llms.txt` (`LlmsTxtController`). Decided by Brian Fisher 2026-11-07 (AntCat data CC BY 4.0) and
# 2026-11-08 (free registered API keys, see `ApiAccess`). The front door itself is never limited or counted.
module Api
  module V1
    class RootController < Api::ApiController
      TERMS = [
        "Use the API, not scraping of AntCat's web pages; follow robots.txt.",
        "Systematic extraction of the whole catalog, mirroring or full synchronization must be arranged " \
        "in advance: antcat@antcat.org.",
        "Cite AntCat: #{ApiAccess::CITATION}",
        "AntCat data are licensed CC BY 4.0 (https://creativecommons.org/licenses/by/4.0/). " \
        "These terms govern access to the API; they do not override the permissions the licence grants.",
        "Larger projects and revisions: AntCat is developed under the scientific leadership of Brian L. Fisher, " \
        "who welcomes collaboration. Write to antcat@antcat.org."
      ].freeze
      # Shown with the terms while API keys are live, and on the key registration form.
      KEY_TERMS = [
        "Keep your API key private; one key per project. Use it to answer research questions, not to copy the catalog.",
        "Respect the limits; we may lower limits or revoke keys that harm the service. " \
        "We count requests per key to plan the service and do not share these counts."
      ].freeze

      skip_before_action :check_api_access
      skip_after_action :count_api_records

      def show
        render json: {
          name: "AntCat API v1",
          about: "AntCat is the online catalog of the ants of the world: valid names, synonyms, " \
                 "taxonomic history and references.",
          status: "open",
          documentation: "https://www.antcat.org/api_docs",
          guide_for_programs: "https://www.antcat.org/llms.txt",
          terms: TERMS,
          api_keys: api_keys_info,
          license: { name: "CC BY 4.0", url: "https://creativecommons.org/licenses/by/4.0/" },
          citation: ApiAccess::CITATION,
          contact: "antcat@antcat.org"
        }
      end

      private

        def api_keys_info
          unless ApiAccess.enabled?
            return {
              status: "coming",
              about: "Free registered API keys are coming and will raise the limits."
            }
          end

          {
            status: "live",
            get_a_key: ApiAccess::REGISTER_URL,
            header: ApiAccess::HEADER,
            terms: KEY_TERMS,
            about: "A free key raises the limits. Send it in the #{ApiAccess::HEADER} header (not in the web " \
                   "address). Lists of all records (for example /v1/taxa, paged with starts_at) need a key.",
            limits: {
              without_key: ApiAccess.describe(ApiAccess::NO_KEY_LIMITS) + " (per IP; lists of all records need a key)",
              with_key: ApiAccess.describe(ApiAccess::REGISTERED_LIMITS),
              larger_projects: "Write to #{ApiAccess::CONTACT}."
            },
            over_the_limit: "HTTP 429 with a Retry-After header (seconds to wait). Please slow down instead of retrying at once.",
            key_not_valid: "HTTP 401."
          }
        end
    end
  end
end
