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
end
