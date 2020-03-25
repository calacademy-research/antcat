# HTTP/2

This recipe enables support for HTTP/2 on `nginx`. Browsers that do not support HTTP/2 are falling back to HTTP/1.1.

## Prerequisites

### SSL certicate

An SSL certificate is required. Instructions on how to obtain and install an SSL certificate can be found [here](https://support.cloud.engineyard.com/hc/en-us/articles/205407488-Obtain-and-Install-SSL-Certificates-for-Applications)

## Installation

For simplicity, we recommend that you create the cookbooks directory at the root of your application. If you prefer to keep the infrastructure code separate from application code, you can create a new repository.

On our main recipe `nginx` HTTP/2 protocol is disabled by default. To enable HTTP/2 you should copy this recipe `custom-http2`. You should not copy the actual `nginx` recipe. This is managed by Engine Yard.

1. Edit `cookbooks/ey-custom/recipes/after-main.rb` and add

      ```
      include_recipe 'custom-http2'
      ```

2. Edit `cookbooks/ey-custom/metadata.rb` and add

      ```
      depends 'custom-http2'
      ```

3. Copy `custom-cookbooks/http2/cookbooks/custom-http2 ` to `cookbooks/`

      ```
      cd ~ # Change this to your preferred directory. Anywhere but inside the application

      git clone https://github.com/engineyard/ey-cookbooks-stable-v6
      cd ey-cookbooks-stable-v6
      cp custom-cookbooks/http2/cookbooks/custom-http2 /path/to/app/cookbooks/
      ```

4. Download the ey-core gem on your local machine and upload the recipes

  ```
  gem install ey-core
  ey-core recipes upload --environment=<nameofenvironment> --file=<pathtocookbooksfolder> --apply
  ```
