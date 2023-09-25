defmodule ParallelSandbox.Repo do
  use Ecto.Repo,
    otp_app: :parallel_sandbox,
    adapter: Ecto.Adapters.Postgres
end
