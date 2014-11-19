module RelayApiClient
  class Base

    def self.client
      @client ||= Savon.client(wsdl: RelayApiClient.wsdl)
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
          if RelayApiClient.linker_username &&
            RelayApiClient.linker_password &&
            l = IdentityLinker::Linker.find_linked_identity('relay_username', username, 'ssoguid')
            return l[:identity][:id_value]
          end
        else
          raise
        end
      end
    end

    # @param [String] ssoguid
    # @param [String] designation
    # @return [Boolean] true if it succeeded, false otherwise.
    def self.set_designation_number(ssoguid, designation)
      response = client.call(:set_designation, message: {ssoguid: ssoguid, designation: designation})

      response.success?
    end
  end
end
