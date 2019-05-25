defmodule GuardianJwks.SecretFetcher do
  @moduledoc """
  An implementation of `Guardian.Token.Jwt.SecretFetcher` for reading public JWKS URLs.

  This secret fetcher is intended to be used when you are _verifying_ a token is signed with
  a well known public key. It only implements the `before_verify/2` callback providing a
  `JOSE.JWK` for the given token. It is important to notice this is not meant for
  use when **GENERATING** a token. So, using this hook with the `Guardian.encode_and_sign`
  function **WILL NOT WORK!!!**

  To use it, configure guardianpass this hook to Joken either with the `add_hook/2` macro or directly
  to each `Joken` function. Example:

      defmodule MyToken do
        use Joken.Config

        add_hook(GuardianJwks, strategy: MyFetchingStrategy)

        # rest of your token config
      end

  Or:

      Joken.verify_and_validate(config, token, nil, context, [{Joken.Jwks, strategy: MyStrategy}])

  ## Fetching strategy

  Very rarely, your authentication server might rotate or block its keys. Key rotation is the
  process of issuing a new key that in time will replace the older key. This is security hygiene
  and should/might be a regular process.

  Sometimes it is important to block keys because they got leaked or for any other reason.

  Other times you simply don't control the authentication server and can't ensure the keys won't
  change. This is the most common scenario for this hook.

  In these cases (and some others) it is important to have a cache invalidation strategy: all your
  cached keys should be refreshed. Since the best strategy might differ for each use case, there
  is a behaviour that can be customized as the "fetching strategy", that is: when to fetch and re-fetch
  keys. `GuardianJwks` has a default strategy that tries to be smart and cover most use cases by default.
  It combines a time based state machine to avoid overflowing the system with re-fetching keys. If  that
  is not a good option for your use case, it can still be configured. Please, see
  `GuardianJwks.SignerMatchStrategy` or `GuardianJwks.DefaultStrategyTemplate` docs for more information.
  """
  @behaviour Guardian.Token.Jwt.SecretFetcher

  @impl true
  def fetch_signing_secret(mod, opts) do
    log_level = opts[:log_level] || apply(mod, :config, [:jwks_log_level])

    GuardianJwks.log(
      :warn,
      log_level,
      "#{inspect(__MODULE__)} does not implement fetch_signing_secret/2."
    )

    {:error, :secret_not_found}
  end

  @doc """
  Fetches a `JOSE.JWK` for the given `token_headers`.

  The JWK returned is based on the value of the `kid` header, which is
  required for JWKS.
  """
  @impl true
  def fetch_verifying_secret(mod, token_headers, opts) do
    log_level = opts[:log_level] || apply(mod, :config, [:jwks_log_level])
    server = opts[:key_server] || apply(mod, :config, [:jwks_key_server])

    with {:ok, kid} <- GuardianJwks.SecretFetcher.get_kid_from_headers(token_headers),
         {:ok, key} <- server.find_key_by_kid(kid, mod, opts) do
      {:ok, key}
    else
      {:error, reason} ->
        GuardianJwks.log(
          :error,
          log_level,
          "#{inspect(mod)} failed fetching verifying secret, reason: #{inspect(reason)}, server: #{inspect(server)}"
        )

        {:error, :secret_not_found}
    end
  end

  @spec get_kid_from_headers(nil | keyword() | map()) ::
          {:error, :no_kid_in_token_headers} | {:ok, any()}
  def get_kid_from_headers(headers) do
    case headers["kid"] do
      kid when not is_nil(kid) -> {:ok, kid}
      _ -> {:error, :no_kid_in_token_headers}
    end
  end
end
