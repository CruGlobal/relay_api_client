module RelayApiClient
  class Base

    def self.client
      @client ||= Savon.client(wsdl: RelayApiClient.wsdl, ssl_verify_mode: :none)
    end

    # @param [String] username
    # @param [String] password
    # @param [String] first_name
    # @param [String] last_name
    # @return [String] Returns the guid of the new account
    def self.create_account(username, password, first_name, last_name)
      password = password.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>','&gt;').gsub("'", "&apos;").gsub("\"", "&quot;")
      begin
        response = client.call(:signup, message: {username: username, password: password, passwordConfirm: password, firstName: first_name, lastName: last_name})

        h = response.to_hash

        if response.success?
          puts h.inspect
          return h[:signup_response][:user][:id]
        else
          case h[:fault][:faultstring]
          when "password does not meet with policy requirements."
            raise h[:fault][:faultstring]
          else
            logger.debug response.inspect
          end
        end
      rescue => e
        if e.message.include?("user already exists")
          # check identity linking
          person_entity = GlobalRegistry::Entity.get(
            'entity_type' => 'person',
            'filters[key_username]' => username,
            'filters[owned_by]' => 'the_key'
          )
          guid = person_entity&.dig('entities', 0, 'person', 'authentication', 'key_guid')
          return guid
        else
          raise
        end
      end
    end

    # @param ssoguid [String]
    # @param designation [String]
    # @return [Boolean] true if it succeeded, false otherwise.
    def self.set_designation_number(ssoguid, designation)
      response = client.call(:set_designation, message: {ssoguid: ssoguid, designation: designation})

      response.success?
    end

    # @param args [Hash] arguments to pass on to SOAP call
    # @return [Boolean] true if it succeeded, false otherwise.
    def self.set_role(args)
      response = client.call(:set_role, message: args)

      response.success?
    rescue Savon::SOAPFault => e
      return true if e.message.include?('duplicate')
      false
    end
  end
end
