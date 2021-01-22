defmodule Fhub.Repo do
  use Ecto.Repo,
    otp_app: :fhub,
    adapter: Ecto.Adapters.Postgres
end
