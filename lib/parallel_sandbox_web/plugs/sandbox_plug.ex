defmodule ParallelSandboxWeb.Plugs.SandboxPlug do
  @moduledoc false

  alias Plug.Conn
  alias ParallelSandbox.SandboxDbConn

  def init(opts), do: opts

  def call(conn, _opts) do
    with group_id when is_binary(group_id) <- get_group_id(conn) do
      IO.inspect("Assigning Sandbox Conn: #{group_id}")
      SandboxDbConn.use(group_id)
    end

    conn
  end

  def get_group_id(conn) do
    with [group_id] <- Conn.get_req_header(conn, "x-req-id") do
      group_id
    end
  end
end
