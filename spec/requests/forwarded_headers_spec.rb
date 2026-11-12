# frozen_string_literal: true

require 'rails_helper'

# The sign-in, sign-up, password reset, feedback and API limits count requests per visitor address
# (`request.remote_ip`). That address must come from the header nginx sets (X-Forwarded-For), never
# from a `Forwarded` header, which only a client can have sent.
describe "Visitor address and the Forwarded header" do
  let(:client_sent) { "203.0.113.9" }
  let(:from_nginx) { "198.51.100.7" }

  def remote_ip_or_refusal
    request.remote_ip
  rescue ActionDispatch::RemoteIp::IpSpoofAttackError
    :refused
  end

  it "reads only the X-Forwarded-* headers" do
    expect(Rack::Request.forwarded_priority).to eq [:x_forwarded]
  end

  it "ignores a Forwarded header when nginx's X-Forwarded-For is there" do
    get "/v1", headers: { "Forwarded" => "for=#{client_sent}", "X-Forwarded-For" => from_nginx }

    expect(remote_ip_or_refusal).to eq(from_nginx).or eq(:refused)
  end

  it "ignores a Forwarded header on its own" do
    get "/v1", headers: { "Forwarded" => "for=#{client_sent}" }

    expect(request.remote_ip).to eq "127.0.0.1"
  end

  describe "nginx (dockerized_app/nginx/default.conf)" do
    let(:proxied_locations) do
      Rails.root.join("dockerized_app/nginx/default.conf").read.
        scan(/^    location [^\n]*\{\n(.*?)^    \}/m).flatten.
        select { |block| block.include?("proxy_pass") }
    end

    it "replaces X-Forwarded-For and clears Client-IP and Forwarded wherever it passes to the app" do
      expect(proxied_locations.size).to be >= 2
      expect(proxied_locations).to all(
        include('proxy_set_header X-Forwarded-For $remote_addr;').
          and(include('proxy_set_header Client-IP "";')).
          and(include('proxy_set_header Forwarded "";'))
      )
    end
  end
end
