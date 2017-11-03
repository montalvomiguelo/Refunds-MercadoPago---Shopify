require_relative 'test_helper'
require 'mercadopago'
require 'openssl'
require 'base64'
require_relative '../app'

class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    App
  end

  def setup
    @hmac = '8DY3hoZOly06ya5U+paOgDKTS+OCNzII386CXyaWt5Y=\n'
    @order_json = { :checkout_id => 12345678901, :gateway => 'mercado_pago' }.to_json
    @refunded_response = { :status => 200, :response => {} }
  end

  def test_it_receives_an_order
    App.any_instance.stubs(:verify_webhook).returns(true)
    App.any_instance.stubs(:refund_order).returns(@refunded_response)

    post '/webhooks/order', @order_json, 'HTTP_X_SHOPIFY_HMAC_SHA256' => @hmac

    assert last_request.has_header? 'HTTP_X_SHOPIFY_HMAC_SHA256'
    assert_equal 200, last_response.status
    assert_equal 'Webhook notification received successfully', last_response.body
  end

  def test_it_halts_an_error_with_invalid_hmac
    App.any_instance.stubs(:verify_webhook).returns(false)

    post '/webhooks/order', @order_json, 'HTTP_X_SHOPIFY_HMAC_SHA256' => ''

    assert_equal 403, last_response.status
    assert_equal "You're not authorized to perform this action", last_response.body
  end

  def test_it_computes_a_digest_to_compare_against_the_received_hmac
    digest = OpenSSL::Digest.new('sha256')
    data = "{\"checkout_id\":12345678901,\"gateway\":\"mercado_pago\"}"
    hmac = "\xF067\x86\x86N\x97-:\xC9\xAET\xFA\x96\x8E\x802\x93K\xE3\x8272\b\xDF\xCE\x82_&\x96\xB7\x96"

    OpenSSL::HMAC.expects(:digest).with(digest, nil, data).returns(hmac)
    Base64.expects(:encode64).with(hmac).returns(@hmac)

    App.any_instance.stubs(:refund_order).returns(@refunded_response)

    post '/webhooks/order', @order_json, 'HTTP_X_SHOPIFY_HMAC_SHA256' => @hmac
  end

  def test_it_verifies_the_wehook
    App.any_instance.stubs(:refund_order).returns(@refunded_response)

    App.any_instance.expects(:verify_webhook).with(@hmac, @order_json).returns(true)

    post '/webhooks/order', @order_json, 'HTTP_X_SHOPIFY_HMAC_SHA256' => @hmac
  end


  def test_it_refunds_the_mercado_pago_payment
    search_results = {
      'response' => {
        'results' => [
          {
            'collection' => { 'id' => 1234567890 }
          }
        ]
      }
    }

    MercadoPago.any_instance.expects(:get).with("/collections/search?external_reference=12345678901").returns(search_results)
    MercadoPago.any_instance.expects(:refund_payment).with('1234567890').returns(@refunded_response)

    App.any_instance.stubs(:verify_webhook).returns(true)

    post '/webhooks/order', @order_json, 'HTTP_X_SHOPIFY_HMAC_SHA256' => @hmac
  end

  def test_it_refunds_the_received_order
    App.any_instance.stubs(:verify_webhook).returns(true)
    App.any_instance.expects(:refund_order).with(12345678901).returns(@refunded_response)
    post '/webhooks/order', @order_json, 'HTTP_X_SHOPIFY_HMAC_SHA256' => @hmac
  end

end
