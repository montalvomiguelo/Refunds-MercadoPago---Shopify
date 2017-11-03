# Refunds MercadoPago Shopify


Te permite hacer devoluciones de Mercado Pago desde desde Shopify

Esto recibe la información que nos manda Shopify cada vez que el evento de `Order cancellation` sucede _(mediante el uso de Webhooks)_. Entonces en ese momento hacemos la devolución con la API de MercadoPago.


## Requerimientos 
* Bundler
* Ruby 2.3.4
* Crea un Webhook en tu tienda Shopify. Indicando que te quieres subscribir al evento de cancelación de ordenes, la URI donde quieres recibir la data cuando el evento suceda y que la quieres recibir en formato JSON:
```
Event: Order cancelation
Callback uri: https://your-server.com/webhooks/order
Format: JSON
```

## Instalación

1. Descarga el proyecto
2. Instala las dependencias `bundle install`
3. Exponer públicamente la aplicación _(con ayuda de [ngrok](https://ngrok.com) para exponerlo desde tu equipo local)_
4. Crear las variables de entorno con un `.env` file
```
SHARED_SECRET=lo-obtienes-al-crear-tu-webhook
CLIENT_ID=tu-id-mercadopago
CLIENT_SECRET=tu-secret-mercadopago
```
5. Iniciar la aplicación `rackup`
