import Config

# Adopted from https://fly.io/docs/getting-started/elixir/#runtime-config
# config/runtime.exs for the :prod config isn't normally run during local use.
# Carefully review it. For the list of runtime configuration settings, see
# https://hexdocs.pm/phoenix/Phoenix.Endpoint.html#module-runtime-configuration

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.
if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  config :url_shortnr, UrlShortnr.Repo,
    url: database_url,
    # IMPORTANT: Or it won't find the DB server
    socket_options: [:inet6],
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  app_name =
    System.get_env("FLY_APP_NAME") ||
      raise "FLY_APP_NAME not available"

  config :url_shortnr, UrlShortnrWeb.Endpoint,
    server: true,
    url: [host: nil],
    http: [
      port: String.to_integer(System.get_env("PORT") || "4000"),
      # IMPORTANT: support IPv6 addresses
      transport_options: [socket_opts: [:inet6]]
    ],
    secret_key_base: secret_key_base,
    check_origin: [
      "//#{app_name}.fly.dev",
      "//mnishiguchi.com",
      "//www.mnishiguchi.com",
      "//link.mnishiguchi.com"
    ]

  # ## Using releases
  #
  # If you are doing OTP releases, you need to instruct Phoenix
  # to start each relevant endpoint:
  #
  #     config :url_shortnr, UrlShortnrWeb.Endpoint, server: true
  #
  # Then you can assemble a release by calling `mix release`.
  # See `mix help release` for more information.
end
