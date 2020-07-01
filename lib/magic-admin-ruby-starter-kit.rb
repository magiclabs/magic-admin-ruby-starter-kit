require "base64"
require "json"
require "Eth"
require "faraday"


# Magic secret API key can be retrieved from the `https://dashboard.magic.link`.
# This secret should be loaded from your env variable or from somewhere safe.
MAGIC_SECRET_API_KEY = "YOUR_SECRET_API_KEY"


class Token

  @@required_fields = ['iat', 'ext', 'nbf', 'iss', 'sub', 'aud', 'tid', 'add'].freeze

    def self.check_required_fields(claim)
        missing_fields = []

        @@required_fields.each do |field|
            if !claim.key?(field)
                missing_fields << field
            end
        end

        if missing_fields.any?
            raise Exception.new "DID Token missing required fields: %s" % missing_fields.join(", ")
        end
    end

    # Decodes a given DID Token
    # This method attempt to decode the passed in DID Token by:
    #   1. First, decoding it with the base64 urlsafe method
    #   2. Second, parsing the result of the base64 decoded string to JSON.
    # The result of these two steps returns a tuple, [proof, claim]. A proof
    # is a cryptographic signature of the claim, which we can use to verify the
    # authenticity of the token.
    #
    # @param [String] :did_token A cryptographically generated token.
    #
    # @return [String] :proof A signed message.
    # @return [Hash] :claim A hash of the unsigned message.
    def self.decode(did_token)
        begin
            decoded_did_token = JSON.parse(Base64.urlsafe_decode64(did_token))
        rescue Exception
            raise Exception.new "Malformed DID Token"
        end

        if decoded_did_token.length != 2
            raise Exception.new "DID Token is malformed"
        end

        proof = decoded_did_token[0]

        begin
            claim = JSON.parse(decoded_did_token[1])
        rescue Exception
            raise Exception.new "DID Token is malformed"
        end

        self.check_required_fields(claim)

        return proof, claim
    end

    # Retrieves the issuer from the DID Token
    # This method parses the passed in DID Token to retrieve the issuer. An issuer
    # has the following format `did:ethr:<public_addresser>`.
    #
    # @param [String] :did_token A cryptographically generated token.
    # 
    # @return [String] The issuer of the token.
    def self.get_issuer(did_token)
        _, claim = self.decode(did_token)

        return claim['iss']
    end

    # Retrieves the public address from the DID Token
    # This method parses the passed in DID Token to retrieve the public address.
    # The public address is an Ethereum public address.
    #
    # @param [String] :did_token A cryptographically generated token.
    # 
    # @return [String] The public address of the DID Token.
    def self.get_public_address(did_token)
        issuer = self.get_issuer(did_token)

        # This can also use regex to parse it.
        return issuer.split(':')[-1]
    end

    # Validates a given DID Token.
    # This method attempts to validate the passed in DID Token. It uses the `proof`
    # and `claim` from the decoded token to verify the signature of the token. If
    # the signature mismatches, it raises an exception. This methods also verifies
    # the expiry time along with the not-before (nbf) fields from the token to
    # ensure the validity of the token.
    #
    # @param [String] :did_token A cryptographically generated token.
    # 
    # @return [Nil].
    def self.validate(did_token)
        proof, claim = self.decode(did_token)
        recovered_public_address = Eth::Utils.public_key_to_address(
            Eth::Key.personal_recover(JSON.dump(claim), proof),
        )

        if recovered_public_address != self.get_public_address(did_token)
            raise Exception.new "Signature mismatch between 'proof' and 'claim'."
        end

        current_time = Time.now.to_i

        if current_time > claim['ext']
            raise Exception.new "Given DID token has expired. Please generate a new one."
        end

        if current_time < claim['nbf']
            raise Exception.new "Given DID token cannot be used at this time."
        end
    end

end


class User

    # Retrieves user metadata from Magic API.
    #
    # @param [String] :issuer The issuer in the following format
    #   `did:ethr:<public_addresser>`
    # 
    # @return [Hash] The response from the HTTP request.
    def self.get_metadata_by_issuer(issuer)
        resp = Faraday.get('https://api.magic.link/v1/admin/auth/user/get') do |req|
            req.params['issuer'] = issuer
            req.headers['X-Magic-Secret-Key'] = MAGIC_SECRET_API_KEY
        end

        return JSON.parse(resp.body)
    end

    # Logs out the user server-side through Magic API.
    #
    # @param [String] :issuer The issuer in the following format
    #   `did:ethr:<public_addresser>`
    # 
    # @return [Hash] The response from the HTTP request.
    def self.logout_by_issuer(issuer)
        resp = Faraday.post('https://api.magic.link/v2/admin/auth/user/logout') do |req|
            req.headers['X-Magic-Secret-Key'] = MAGIC_SECRET_API_KEY
            req.headers['Content-Type'] = 'application/json'
            req.body = {'issuer': issuer}.to_json
        end

        return JSON.parse(resp.body)
    end

end
