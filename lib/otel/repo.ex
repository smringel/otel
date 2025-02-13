defmodule Otel.Repo do
  use Ecto.Repo,
    otp_app: :otel,
    adapter: Ecto.Adapters.Postgres
end
