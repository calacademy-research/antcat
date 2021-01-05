# frozen_string_literal: true

# See https://support.cloud.engineyard.com/hc/en-us/articles/115004734428-Using-yarn-to-manage-NodeJS-modules-for-assets-compilation
run! "cd #{config.release_path} && ./bin/yarn"
