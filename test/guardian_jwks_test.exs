defmodule GuardianJwksTest do
  use ExUnit.Case, async: true

  test "fails if token has no kid" do
    header = %{"alg" => "RS256"} |> Jason.encode!() |> Base.url_encode64(padding: false)
    payload = %{} |> Jason.encode!() |> Base.url_encode64(padding: false)
    token = "#{header}.#{payload}.signature"
    opts = [strategy: GuardianJwksTest]

    assert {:halt, {:error, :no_kid_in_token_header}} ==
             GuardianJwks.before_verify(opts, {token, nil})
  end

  test "fails if token malformed" do
    opts = [strategy: GuardianJwksTest]

    assert {:halt, {:error, :token_malformed}} == GuardianJwks.before_verify(opts, {"asd.asd", nil})
  end

  test "raises if no strategy provided" do
    assert_raise(RuntimeError, fn -> GuardianJwks.before_verify([], {"asd.asd", nil}) end)
  end
end
