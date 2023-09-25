defmodule ParallelSandboxWeb.SandboxController do
  use ParallelSandboxWeb, :controller

  alias ParallelSandbox.SandboxDbConn

  action_fallback ParallelSandboxWeb.FallbackController

  def create(conn, %{"group_id" => group_id}) do
    {:ok, pid} =
      DynamicSupervisor.start_child(
        ParallelSandbox.SandboxConnSupervisor,
        {ParallelSandbox.SandboxDbConn, [group_id: group_id]}
      )

    IO.inspect("Started Sandbox Conn: #{group_id}/#{inspect(pid)}")

    conn
    |> put_status(:created)
    |> render(:show, %{})
  end

  def delete(conn, %{"id" => group_id}) do
    SandboxDbConn.close(group_id)

    owner = SandboxDbConn.pid_for_group_id(group_id)

    DynamicSupervisor.terminate_child(
      ParallelSandbox.SandboxConnSupervisor,
      owner
    )

    IO.inspect("Closed Sandbox Conn: #{group_id}/#{inspect(owner)}")

    send_resp(conn, :no_content, "")
  end
end
