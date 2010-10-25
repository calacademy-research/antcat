require 'net/http'

# Adds the validates_http_url class method to ActiveRecord subclasses.

module ActiveRecord
  module Validations
    module ClassMethods
      
      # Validates that a URL is accessible and is an HTTP URL by opening a
      # connection to the server.
      #
      #  class Company < ActiveRecord::Base
      #    validates_http_url :homepage, :wrong_response => "did not return a successful HTTP code"
      #  end
      #
      # Configuration options:
      #
      # * +valid_responses+ - An array of valid HTTP responses (as subclasses of
      #   <tt>Net::HTTPResponse</tt>). By default this contains
      #   <tt>Net::HTTPSuccess</tt> (and therefore all subclasses of it, such as
      #   <tt>Net::HTTPOK</tt>). If you would like to add your own valid
      #   responses, make sure to include <tt>Net::HTTPSuccess</tt> unless you
      #   explicitly want to remove it from the set of valid responses.
      # * +wrong_response+ - A custom error message for when the server does not
      #   return a valid HTTP response
      # * +wrong_protocol+ - A custom error message for when the URL provided is
      #   not an HTTP URL
      # * +malformed_url+ - A custom error message for when a malformed URL is
      #   provided
      # * +no_response+ - A custom error message for when there is no response,
      #   the connection is refused, or unexpectedly reset
      # * +timeout+ - A custom error message for when the connection times out
      # * +message+ - A custom error message to be used for any of the above
      #   error messages that are not specified
      #
      # If you would like to specify a custom error message for a particular
      # response code, pass a hash instead of a string for +wrong_response+. Map
      # each <tt>Net::HTTPResponse</tt> subclass to the error message you'd like
      # to use for that response. If you map an error message to
      # <tt>Net::HTTPResponse</tt>, it will be used as the default error message
      # for response codes without custom error messages. An example:
      #
      #  validates_http_url :url, :wrong_response => { Net::HTTPMovedPermanently => "has been moved", Net::HTTPResponse => "is not working correctly" }
      
      def validates_http_url(*params)
        # Set up config parameters
        configuration = {
          :wrong_response => "is not working correctly",
          :wrong_protocol => "must be the URL for a website",
          :malformed_url => 'is an invalid URL (did you remember the "http://"?)',
          :no_response => "is not accessible",
          :timeout => "is taking too long to respond",
          :valid_responses => [ Net::HTTPSuccess ]
        }
        config_changes = params.extract_options!
        if config_changes[:message] then
          [ :wrong_response, :wrong_protocol, :malformed_url, :no_response ].each { |msg| config_changes[msg] ||= config_changes[:message] }
        end
        configuration.update config_changes
        configuration[:wrong_response][Net::HTTPResponse] ||= (configuration[:message] || "is not working correctly") if configuration[:wrong_response].kind_of? Hash
        
        # Perform validation
        validates_each params, configuration do |record, field, value|
          next if value.nil? or value.empty?
          begin
            uri = URI.parse(value)
            if uri.kind_of? URI::HTTP then
              response = Net::HTTP.get_response(uri)
              error_msg = if configuration[:wrong_response].kind_of? Hash then
                configuration[:wrong_response][response.class.ancestors.detect { |supertype| configuration[:wrong_response].key?(supertype) }]
              else
                configuration[:wrong_response]
              end
              record.errors.add(field, error_msg) unless configuration[:valid_responses].any? { |valid_response| response.kind_of? valid_response }
            else
              record.errors.add(field, configuration[:wrong_protocol])
            end
          rescue URI::InvalidURIError
            record.errors.add field, configuration[:malformed_url]
          rescue SocketError, Errno::ECONNREFUSED, Errno::ECONNRESET, Errno::EHOSTUNREACH
            record.errors.add field, configuration[:no_response]
          rescue Timeout::Error
            record.errors.add field, configuration[:timeout]
          end
        end
      end
    end
  end
end
