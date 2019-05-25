defmodule GuardianJwks.KeyStorage do
  @moduledoc """
  A generic behaviour for fetching a `JOSE.JWK`.
  """
  @callback find_key_by_kid(kid :: binary(), mod :: module(), opts :: any()) ::
              {:ok, map() | JOSE.JWK.t()} | {:error, reason :: atom()}
end
