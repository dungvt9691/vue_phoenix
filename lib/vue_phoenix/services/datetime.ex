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

  def parse_date(date_as_string, format) do
    with {:ok, date} <- Timex.parse(date_as_string, format, :strftime) do
      date
    else
      _ -> nil
    end
  end
end
