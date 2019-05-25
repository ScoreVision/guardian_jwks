use Mix.Config

config :tesla, GuardianJwks.HttpFetcher, adapter: Tesla.Adapter.Hackney
