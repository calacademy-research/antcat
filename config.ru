# This file is used by Rack-based servers to start the application.
require File.expand_path "../config/environment", __FILE__

use Rack::Cors do
  allow do
    origins '*'
    resource '/swagger.yaml',
             headers: :any,
             expose: ['X-User-Authentication-Token', 'X-User-Id'],
             methods: [:get, :post, :options, :patch, :delete]

    resource '/swagger-ui/*',
             headers: :any,
             expose: ['X-User-Authentication-Token', 'X-User-Id'],
             methods: [:get, :post, :options, :patch, :delete]

  end
end
run AntCat::Application
