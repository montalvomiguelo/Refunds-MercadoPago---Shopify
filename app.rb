class App < Sinatra::Base
  API_KEY = ENV['API_KEY']
  API_SECRET = ENV['API_SECRET']
  APP_URL = '3104006d.ngrok.io'

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
  end
end
