defmodule TypoKart.Repo do
  use Ecto.Repo,
    otp_app: :typo_kart,
    adapter: Ecto.Adapters.Postgres
end
