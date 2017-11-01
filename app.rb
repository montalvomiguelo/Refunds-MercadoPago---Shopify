require './models/shop'
require 'mercadopago'

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

    instantiate_session(shop)

    create_order_webhook

    redirect '/'
  end

  post '/webhooks/order' do
    hmac = request.env['HTTP_X_SHOPIFY_HMAC_SHA256']

    request.body.rewind
    data = request.body.read

    verify_webhook!(hmac, data)

    shop = request.env['HTTP_X_SHOPIFY_SHOP_DOMAIN']

    halt 403, "You're not authorized to perform this action" unless Shop.first(name: shop)

    instantiate_session(shop)

    json_data = JSON.parse data

    gateway = json_data['gateway']
    checkout_id = json_data['checkout_id']

    refund(checkout_id) if gateway == 'mercado_pago'

    return [200, 'Webhook notification received successfully']
  end

  get '/' do
    'Hello world!'
  end

  helpers do
    def refund(checkout_id)
      mp = MercadoPago.new(ENV['CLIENT_ID'], ENV['CLIENT_SECRET'])

      response = mp.get("/collections/search?external_reference=#{checkout_id}")['response']

      results = response['results']

      return unless results.any?

      payment = results.first

      payment_id = payment['collection']['id'].to_s

      mp.refund_payment(payment_id)
    end

    def instantiate_session(shop)
      shop = Shop.first(name: shop)

      session = ShopifyAPI::Session.new(shop.name, shop.token)
      ShopifyAPI::Base.activate_session(session)
    end

    def validate_hmac!(hmac, request)
      h = request.params.reject{|k,v| k == 'hmac' || k == 'signature'}
      query = URI.escape(h.sort.collect{|k,v| "#{k}=#{v}"}.join('&'))
      digest = OpenSSL::Digest.new('sha256')
      mac = OpenSSL::HMAC.hexdigest(digest, API_SECRET, query)

      halt 403, "Authentication failed. Digest provided was #{mac}" unless hmac == mac
    end

    def get_shop_access_token!(shop, client_id, client_secret, code)
      return if Shop.first(name: shop)

      url = "https://#{shop}/admin/oauth/access_token"

      payload = {
        client_id: client_id,
        client_secret: client_secret,
        code: code
      }

      response = HTTParty.post(url, body: payload)

      halt 500, 'Something went wrong' unless response.code == 200

      token = response['access_token']

      Shop.create(name: shop, token: token)
    end
  end

  def create_order_webhook
    return if ShopifyAPI::Webhook.find(:all).any?

    webhook = {
      topic: 'orders/cancelled',
      address: "https://#{APP_URL}/webhooks/order",
      format: 'json'
    }

    ShopifyAPI::Webhook.create(webhook)
  end

  def verify_webhook!(hmac, data)
    digest = OpenSSL::Digest.new('sha256')
    calculated_hmac = Base64.encode64(OpenSSL::HMAC.digest(digest, API_SECRET, data)).strip

    halt 403, "You're not authorized to perform this action" unless hmac == calculated_hmac
  end
end
