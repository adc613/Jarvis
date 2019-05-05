defmodule Start.Repo do
  use Ecto.Repo,
    otp_app: :start,
    adapter: Ecto.Adapters.Postgres
end
