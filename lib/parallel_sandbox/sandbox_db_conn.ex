defmodule ParallelSandbox.SandboxDbConn do
  @moduledoc false

  use GenServer

  alias Ecto.Adapters.SQL.Sandbox

  def start_link(opts) do
    group_id =
      opts
      |> Keyword.get(:group_id)
      |> group_id_to_atom()

    GenServer.start_link(__MODULE__, opts, name: group_id)
  end

  def use(group_id) do
    owner_process = pid_for_group_id(group_id)

    GenServer.call(owner_process, {:use, self()})
  end

  def close(group_id) do
    owner_process = pid_for_group_id(group_id)

    GenServer.call(owner_process, :close)
  end

  def pid_for_group_id(group_id) do
    group_id_atom = group_id_to_atom(group_id)

    Process.whereis(group_id_atom)
  end

  defp group_id_to_atom(group_id) do
    # We use to_atom here instead of the safer to_existing_atom/1 because
    # we are using uuid's to track the database connections
    String.to_atom(group_id)
  end

  def init(_opts) do
    {:ok, %{}, {:continue, :open_conn}}
  end

  def handle_continue(:open_conn, state) do
    :ok = Sandbox.checkout(ParallelSandbox.Repo)

    {:noreply, state}
  end

  def handle_call({:use, caller}, _, state) do
    Sandbox.allow(ParallelSandbox.Repo, self(), caller)

    {:reply, :ok, state}
  end

  def handle_call(:close, _, state) do
    :ok = Sandbox.checkin(ParallelSandbox.Repo)

    {:reply, :ok, state}
  end
end
