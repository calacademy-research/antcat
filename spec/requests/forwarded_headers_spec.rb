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

  # In production a request comes Cloudflare -> nginx -> Puma. nginx takes the visitor's address from
  # Cloudflare's `CF-Connecting-IP` header (only on connections from Cloudflare's own ranges) and passes
  # it on as X-Forwarded-For; Puma sees nginx's address on the Docker network as the sender.
  describe "a visitor through Cloudflare and nginx" do
    let(:visitor) { "198.51.100.7" }
    let(:nginx_container) { "172.18.0.5" }

    it "is the visitor's own address, not Cloudflare's or nginx's" do
      get "/v1", headers: { "X-Forwarded-For" => visitor }, env: { "REMOTE_ADDR" => nginx_container }

      expect(request.remote_ip).to eq visitor
    end

    it "is the same for an IPv6 visitor" do
      get "/v1", headers: { "X-Forwarded-For" => "2001:db8::7" }, env: { "REMOTE_ADDR" => nginx_container }

      expect(request.remote_ip).to eq "2001:db8::7"
    end

    # nginx passes the request's other headers on unchanged. Rails itself never reads this one.
    it "ignores a CF-Connecting-IP header that reaches the app" do
      headers = { "CF-Connecting-IP" => client_sent, "X-Forwarded-For" => visitor }
      get "/v1", headers: headers, env: { "REMOTE_ADDR" => nginx_container }

      expect(request.remote_ip).to eq visitor
    end
  end

  describe "nginx (dockerized_app/nginx/default.conf)" do
    let(:nginx_conf) { Rails.root.join("dockerized_app/nginx/default.conf").read }
    let(:proxied_locations) do
      nginx_conf.scan(/^    location [^\n]*\{\n(.*?)^    \}/m).flatten.select { |block| block.include?("proxy_pass") }
    end

    # Without this, every visitor behind one Cloudflare edge would share an address (and one API limit).
    it "takes the visitor's address from CF-Connecting-IP, only for connections from Cloudflare's ranges" do
      trusted = nginx_conf.scan(/^set_real_ip_from ([^;]+);/).flatten

      expect(nginx_conf).to include "\nreal_ip_header CF-Connecting-IP;\n"
      expect(trusted).to include "173.245.48.0/20", "104.16.0.0/13", "172.64.0.0/13", "2606:4700::/32"
      expect(trusted.size).to be >= 22
      # Never every address: then any client could send the header and choose its own address.
      expect(trusted).not_to include "0.0.0.0/0", "::/0"
      expect(nginx_conf).not_to match(/^\s*real_ip_recursive\s+on/)
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
