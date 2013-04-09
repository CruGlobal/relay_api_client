module RelayApiClient
  class Base

    def self.client
      @client ||= Savon.client(wsdl: RelayApiClient.wsdl)
    end

    # returns a guid or nil
    def self.create_account(username, password, first_name, last_name)
      password = password.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>','&gt;').gsub("'", "&apos;").gsub("\"", "&quot;")
      response = client.call(:signup, message: {username: username, password: password, passwordConfirm: password, firstName: first_name, lastName: last_name})

      h = response.to_hash

      if response.success?
        puts h.inspect
        return h[:signup_response][:user][:id]
      else
        case h[:fault][:faultstring]
        when "password does not meet with policy requirements."
          raise h[:fault][:faultstring]
        when "user already exists"
          # check identity linking
          if RelayApiClient.linker_username &&
             RelayApiClient.linker_password &&
             l = IdentityLinker::Linker.find_linked_identity('username',username,'ssoguid')
            return l[:identity][:id_value]
          end
        else
          logger.debug response.inspect
        end
      end

      nil
    end

  end
end
