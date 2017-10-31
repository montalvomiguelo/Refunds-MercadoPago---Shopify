describe App do
  include Rack::Test::Methods

  def app
    App
  end

  describe 'Installation' do
    it 'redirects to Shopify app installation screen' do
      get '/install'
      follow_redirect!
    end
  end
  describe 'Authenticates with Shopify' do

    context 'with valid HMAC' do
      it 'validates hmac' do
        expect_any_instance_of(App).to receive(:validate_hmac!)
        get '/auth'
      end

      #it 'request Auth token to Shopify' do
        #skip
      #end

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
        get '/auth'
        expect(last_response).not_to be_ok
        expect(last_response.status).to eq(403)
      end
    end
  end
end
