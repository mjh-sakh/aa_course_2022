require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Aa_auth < OmniAuth::Strategies::OAuth2
      def initialize(app, *args, &block)
        super
        require 'logger'
        @logger = Logger.new(STDOUT)
      end

      option :name, :aa_auth

      option :client_options, {
          :site => 'http://0.0.0.0:3001',
          :authorize_url => 'http://0.0.0.0:3001/oauth/authorize',
      }

      def request_phase
        # @logger.info "I'm here"
        super
      end

      uid { raw_info['id'] }

      info do
        {
            :id => raw_info['id'],
            :email => raw_info['email'],
            :full_name => raw_info['full_name'],
            :position => raw_info['position'],
            :active => raw_info['active'],
            :role => raw_info['role']
        }
      end

      def raw_info
        @raw_info ||= access_token.get('/accounts/current').parsed
      end
    end

    class Aa_auth < OmniAuth::Strategies::OAuth2

    end
  end
end
