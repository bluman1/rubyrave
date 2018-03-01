module Rubyrave
    class Client
  
      include HTTParty
      format :json

      RAVE_SANDBOX_URL = "http://flw-pms-dev.eu-west-1.elasticbeanstalk.com/"
      RAVE_LIVE_URL = "https://api.ravepay.co/"

      base_uri RAVE_SANDBOX_URL
  
      attr_accessor :public_key, :secret_key, :http_timeout, :mode, :payment_method, :pbfpubkey
  
      def initialize(public_key, secret_key, pbfpubkey, mode = "test", payment_method = 'sas', http_timeout = 25)
        self.public_key = public_key
        self.secret_key = secret_key
        self.pbfpubkey = pbfpubkey
        self.http_timeout = http_timeout
        self.mode = mode
        if mode == "test"
            self.class.base_uri RAVE_SANDBOX_URL
        else
            self.class.base_uri RAVE_LIVE_URL
        end
      end
      
      
    # Functions to have
    # 1. initialize() pass live or test keys to this function. DONE
    # 2. SetMode() switch between live mode and test mode.  DONE
    # 3. Encrypt3DES() performs 3DES encryption on key and payload DONE 
    # 4. getKey() This generates the key using the secret key DONE
    # 5. DirectCharge()  required param is client, the rest is in the library DONE
    # 6. ValidateCardCharge() transacionReference and OTP required
    # 7. ValidateAccountCharge() same as above
    # 8. VerifyTransaction() flw_ref, seckey, normalize=1 required tx_ref optional
    # 9. VerifyTransactionXrequery() flw_ref, seckey, tx_ref, last_attemp, only_successful
    # 10. ListBanks() DONE
    # 11. ConversionRate() requires seckey origin_currency destination_currency optional amount
    # 12. StopRecurringPayment() id of recurring payment and seckey
    # 13. ListRecurringTransactions() seckey only
    # 14. ListSingleRecurringPayment() seckey tx_id
    # 15. PreautorizeCard() client seckey alg
    # 16. CapturePayment() seckey ref
    # 17. RefundPayment() seckey ref action=refund
    # 18. VoidPayment() seckey ref action=void
    # 19. ChargeWithToken() long list of body params
    # 20. SetPaymentMethod() 
    # 21. CreateIntegrityChecksum() DONE

      def set_mode(mode)
        self.mode = mode
      end

      def set_payment_method(payment_meethod)
        self.payment_method = payment_method
      end

      def encrypt(key, data)
        cipher = OpenSSL::Cipher::Cipher.new(“des3”)
        cipher.encrypt # Call this before setting key or iv
        cipher.key = key
        ciphertext = cipher.update(data)
        ciphertext << cipher.final
        return  Base64.encode64(ciphertext)
      end

      def get_key(stuff)
        hash = Digest::MD5.hexdigest("this is a test")
        last_twelve = hash[hash.length-13..hash.length-1]
        private_secret_key = self.secret_key
        private_secret_key['FLWSECK-'] = ''
        first_twelve = private_secret_key[0..11]
        return first_twelve + last_twelve
      end

      def checksum(payload)
        payload.sort_by { |k,v| k.to_s }
        hashed_payload = ''
        family.each { |k,v| 
          hashed_payload << v
        }
        return Digest::SHA256.hexdigest(hashed_payload + self.secret_key)
      end

      def list_banks()
        perform_get('flwv3-pug/getpaidx/api/flwpbf-banks.js', {:json => 1})
      end

      def direct_charge(client_data)
        payload = {
          "PBFPubKey": self.pbfpubkey,
          "client": client_data,
          "alg": "3DES-24"
        }
        perform_post('flwv3-pug/getpaidx/api/charge', payload)
      end

      def perform_get(endpoint, params = {})
        http_params = {}
        unless params.empty?
          http_params[:query] = params
        end
        unless self.http_timeout.nil?
          http_params[:timeout] = self.http_timeout
        end
        self.class.get("/#{endpoint}", http_params)
      end

      def perform_post(endpoint, data)
        self.class.post(endpoint,
        { 
          :body => data.to_json,
          :headers => { 'Content-Type' => 'application/json', 'Accept' => 'application/json'}
        })
      end

    end
end
