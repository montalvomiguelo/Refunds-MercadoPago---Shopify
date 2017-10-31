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
end
