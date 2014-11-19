require 'savon'
require 'identity_linker'

module RelayApiClient
  class << self
    attr_accessor :wsdl, :linker_username, :linker_password

    def configure
      yield self

      self.wsdl ||= 'https://signin.cru.org/sso/selfservice/webservice/5.0?wsdl'

      if linker_username && linker_password
        IdentityLinker.configure do |c|
          c.server_id = linker_username
          c.server_secret = linker_password
        end
      end
    end
  end
end


Dir[File.dirname(__FILE__) + '/relay_api_client/*.rb'].each do |file|
  require file
end
