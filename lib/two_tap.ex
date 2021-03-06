defmodule TwoTap do
  use Application

  @two_tap_api Application.fetch_env!(:two_tap, :two_tap_api)

  def start(_type, _args) do
    import Supervisor.Spec, warn: :false

    children = [
      Plug.Adapters.Cowboy.child_spec(:http, TwoTap.Router, [], [port: 4004]),
      worker(TwoTap.AMQPConsumer, []),
      supervisor(TwoTap.CheckoutSupervisor, [])
    ]

    opts = [strategy: :one_for_one, name: TwoTap.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def checkout(products, purchase_data) do
    create_cart(products)
    |> start_purchase(purchase_data)
  end

  def create_cart(products) do
    @two_tap_api.create_cart(products)
  end

  # may need to get site_id in order to make purchase
  def get_cart_status(cart_id) do
    @two_tap_api.get_cart_status(cart_id)
  end

  def start_purchase(cart_id, purchase_data) do
    @two_tap_api.start_purchase(cart_id, purchase_data)
  end

  def confirm_purchase(purchase_id) do
    @two_tap_api.confirm_purchase(purchase_id)
  end

  def fetch_product_catalog(params) do
    @two_tap_api.fetch_product_catalog(params)
  end
end
