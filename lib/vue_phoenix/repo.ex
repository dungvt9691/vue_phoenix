defmodule VuePhoenix.Repo do
  use Ecto.Repo,
    otp_app: :vue_phoenix,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 20

  def reload!(%module{id: id}) do
    get(module, id)
  end
end
