ExUnit.configure(exclude: [external: true])
ExUnit.start()
Mox.defmock(TeslaAdapterMock, for: Tesla.Adapter)
Application.put_env(:tesla, GuardianJwks.HttpFetcher, adapter: TeslaAdapterMock)
