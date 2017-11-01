describe App do
  include Rack::Test::Methods

  def app
    App
  end

  describe 'Installation' do
    it 'redirects to Shopify app installation screen' do
      skip
      get '/install'
      follow_redirect!
    end
  end

  describe 'Authenticates with Shopify' do
    context 'with valid HMAC' do
      it 'validates hmac' do
        skip
        expect_any_instance_of(App).to receive(:validate_hmac!)
        allow_any_instance_of(App).to receive(:get_shop_access_token!).and_return(nil)
        get '/auth'
      end

      it 'gets access token from Shopify' do
        skip
        allow_any_instance_of(App).to receive(:validate_hmac!).and_return(nil)
        expect_any_instance_of(App).to receive(:get_shop_access_token!)
        get '/auth'
      end

      it 'stores token into database' do
        skip
        allow_any_instance_of(App).to receive(:validate_hmac!).and_return(nil)

        allow_any_instance_of(App).to receive(:get_shop_access_token!) do |store, token|
          Shop.create(name: store, token: token)
        end

        expect(Shop).to receive(:create)

        get '/auth'
      end

      #it 'creates a webhook for order cancelation' do
        #skip
      #end

      #it 'redirects to create a new mercado pago account' do
        #skip
        #follow_redirect!
      #end
    end

    context 'with invalid HMAC' do
      it 'halts a 403 error' do
        skip
        get '/auth'
        expect(last_response).not_to be_ok
        expect(last_response.status).to eq(403)
      end
    end
  end
end
