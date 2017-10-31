class App < Sinatra::Base
  API_KEY = ENV['API_KEY']
  API_SECRET = ENV['API_SECRET']
  APP_URL = 'cd7c2896.ngrok.io'

  get '/install' do
    shop = params[:shop]
    scopes = 'read_orders'

    install_url = "https://#{shop}/admin/oauth/authorize?client_id=#{API_KEY}&scope=#{scopes}&redirect_uri=https://#{APP_URL}/auth"

    redirect install_url
  end

  get '/auth' do
    shop = params[:shop]
    code = params[:code]
    hmac = params[:hmac]

    validate_hmac!(hmac, request)

    get_shop_access_token!(shop, API_KEY, API_SECRET, code)

    'Valid hmac'
  end

  helpers do
    def validate_hmac!(hmac, request)
      h = request.params.reject{|k,v| k == 'hmac' || k == 'signature'}
      query = URI.escape(h.sort.collect{|k,v| "#{k}=#{v}"}.join('&'))
      digest = OpenSSL::Digest.new('sha256')
      mac = OpenSSL::HMAC.hexdigest(digest, API_SECRET, query)

      halt 403, "Authentication failed. Digest provided was #{mac}" unless hmac == mac
    end

    def get_shop_access_token!(shop, client_id, client_secret, code)
      url = "https://#{shop}/admin/oauth/access_token"

      payload = {
        client_id: client_id,
        client_secret: client_secret,
        code: code
      }

      response = HTTParty.post(url, body: payload)

      halt 500, 'Something went wrong' unless response.code == 200

      token = response['access_token']

      puts token
    end
  end
end
