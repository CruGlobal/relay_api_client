require 'savon'

module RelayApiClient
  class << self
    attr_accessor :wsdl, :linker_username, :linker_password

    def configure
      yield self

      self.wsdl ||= 'https://signin.cru.org/sso/selfservice/webservice/5.0?wsdl'
    end
  end
end


Dir[File.dirname(__FILE__) + '/relay_api_client/*.rb'].each do |file|
  require file
end
