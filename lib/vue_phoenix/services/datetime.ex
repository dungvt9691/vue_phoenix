defmodule VuePhoenix.Services.DateTime do
  @moduledoc false

  def parse_date(nil), do: nil

  def parse_date(date_as_string) do
    with {:ok, date, _} <- DateTime.from_iso8601(date_as_string) do
      date
    else
      _ -> date_as_string
    end
  end
end
