require "multi_json"
require "omniauth"
require "oauth"

# for Hash#to_query
require "active_support"
require "active_support/core_ext"

module OmniAuth
  module Strategies

    class KhanAcademy
      include OmniAuth::Strategy
      option :name, "khan_academy"

      args [:consumer_key, :consumer_secret]

      option :consumer_key, nil
      option :consumer_secret, nil
      option :callback_url, nil
      option :client_options, nil

      DEFAULT_CLIENT_OPTIONS = {
        "http_method" => :post,
        "site" => "https://www.khanacademy.org",
        "request_token_path" => "/api/auth2/request_token",
        "access_token_path" => "/api/auth2/access_token",
        "authorize_path" => "/api/auth2/authorize"
      }

      attr_reader :access_token

      # this will retrieve the request token and then redirect to the KhanAcademy login page
      # where you can login using google, facebook or khan's login
      # Khan returns the required credentials for the request token after authentication
      def request_phase
        @request_token = consumer.get_request_token({exclude_callback: true}, {oauth_callback: callback_url})
        session[:request_token] = @request_token
        puts @request_token.authorize_url
        redirect @request_token.authorize_url
      end


      def callback_phase
        raise OmniAuth::NoSessionError.new("Session Expired") if session[:request_token].nil?
        # Create a request token from the token and secret provided in the response
        request_token = ::OAuth::RequestToken.new(consumer, request["oauth_token"], request["oauth_token_secret"])
        # Request access_token from the created request_token
	      @access_token = request_token.get_access_token(oauth_verifier: request['oauth_verifier'])
        super
      rescue ::Timeout::Error => e
        fail!(:timeout, e)
      rescue ::Net::HTTPFatalError, ::OpenSSL::SSL::SSLError => e
        fail!(:service_unavailable, e)
      rescue ::OAuth::Unauthorized => e
        fail!(:invalid_credentials, e)
      rescue ::MultiJson::DecodeError => e
        fail!(:invalid_response, e)
      rescue ::OmniAuth::NoSessionError => e
        fail!(:session_expired, e)
      end

      def raw_info
        @raw_info ||= MultiJson.decode(access_token.get("/api/v1/user").body)
      end

      uid do
        raw_info["user_id"]
      end

      credentials do
        {"token" => access_token.token, "secret" => access_token.secret}
      end

      extra do
        {"access_token" => access_token, "raw_info" => raw_info}
      end

      info do
        {
          "email" => raw_info["email"],
          "nickname" => raw_info["nickname"]
        }
      end

      def client_options
        DEFAULT_CLIENT_OPTIONS.merge(options.client_options || {})
      end

      def callback_url
        options.callback_url || super
      end


      def consumer
        @consumer ||= ::OAuth::Consumer.new(options.consumer_key, options.consumer_secret, client_options)
      end
    end

  end
end
