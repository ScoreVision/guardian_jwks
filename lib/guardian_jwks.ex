defmodule GuardianJwks do
  @moduledoc """
  `Guardian` extension for fetching `JOSE.JWK`s from public JWKS URLs.

  ## KeyServer

      defmodule MyApp.MyKeyServer do
        use GuardianJwks.KeyServer

        def init_opts(opts) do
          Keyword.merge(opts, jwks_url: "https://example.com/.well-known/jwks.json")
        end
      end

  ## Configuration

      config :my_app, MyApp.Guardian,
        secret_fetcher: GuardianJwks.SecretFetcher,
        jwks_key_server: MyApp.MyKeyServer
  """
  require Logger

  @spec log(level :: atom(), min_level :: atom(), message :: binary()) ::
          nil | :ok | {:error, any()}
  def log(_, :none, _), do: :ok

  def log(level, min_level, msg) when level == :debug do
    unless Logger.compare_levels(:debug, min_level) == :lt, do: Logger.debug(fn -> msg end)
  end

  def log(:info, min_level, msg) do
    unless Logger.compare_levels(:info, min_level) == :lt, do: Logger.info(fn -> msg end)
  end

  def log(:warn, min_level, msg) do
    unless Logger.compare_levels(:warn, min_level) == :lt, do: Logger.warn(fn -> msg end)
  end

  def log(:error, _, msg), do: Logger.error(msg)
end
