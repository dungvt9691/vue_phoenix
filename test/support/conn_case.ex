defmodule VuePhoenixWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate
  alias Ecto.Adapters.SQL.Sandbox

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      alias VuePhoenixWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint VuePhoenixWeb.Endpoint
    end
  end

  setup tags do
    :ok = Sandbox.checkout(VuePhoenix.Repo)

    on_exit(fn ->
      VuePhoenix.FileCase.remove_test_files()
    end)

    unless tags[:async] do
      Sandbox.mode(VuePhoenix.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
