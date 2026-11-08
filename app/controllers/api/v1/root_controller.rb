# frozen_string_literal: true

# The front door of the AntCat API (`GET /v1`): what the API is, its terms of use, the licence, how to cite and
# where the documentation is. Programs and AI agents read it before they send requests; it is also the address
# Cloudflare lets through without a challenge (only `/v1/` paths are), so it carries the same guidance as
# `public/llms.txt`. Decided by Brian Fisher 2026-11-07 (AntCat data CC BY 4.0, free registered API keys to come).
module Api
  module V1
    class RootController < Api::ApiController
      TERMS = [
        "Use the API, not scraping of AntCat's web pages; follow robots.txt.",
        "Systematic extraction of the whole catalog, mirroring or full synchronization must be arranged " \
        "in advance: antcat@antcat.org. Free registered API keys are coming and will raise the limits.",
        "Cite AntCat: Bolton, B. <year>. An online catalog of the ants of the world. Available from https://antcat.org. (accessed <date>)",
        "AntCat data are licensed CC BY 4.0 (https://creativecommons.org/licenses/by/4.0/). " \
        "These terms govern access to the API; they do not override the permissions the licence grants.",
        "Larger projects and revisions: AntCat is developed under the scientific leadership of Brian L. Fisher, " \
        "who welcomes collaboration. Write to antcat@antcat.org."
      ].freeze

      def show
        render json: {
          name: "AntCat API v1",
          about: "AntCat is the online catalog of the ants of the world: valid names, synonyms, " \
                 "taxonomic history and references.",
          status: "open",
          documentation: "https://www.antcat.org/api_docs",
          guide_for_programs: "https://www.antcat.org/llms.txt",
          terms: TERMS,
          license: { name: "CC BY 4.0", url: "https://creativecommons.org/licenses/by/4.0/" },
          contact: "antcat@antcat.org"
        }
      end
    end
  end
end
