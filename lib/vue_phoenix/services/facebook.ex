defmodule VuePhoenix.Services.Facebook do
  alias VuePhoenix.Services.DateTime

  @moduledoc false
  @fields "birthday,email,first_name,last_name,middle_name,picture.type(large)"

  def sign_in(access_token) do
    case Facebook.me(@fields, access_token) do
      {:ok, response} ->
        response
        |> download_avatar()
        |> build_data

      error ->
        error
    end
  end

  defp download_avatar(response) do
    %HTTPoison.Response{body: body} = HTTPoison.get!(response["picture"]["data"]["url"])

    File.write!("/tmp/download.jpg", body)

    Map.put(response, "avatar", %Plug.Upload{path: "/tmp/download.jpg", filename: "download.jpg"})
  rescue
    _err ->
      response
  end

  defp build_data(response) do
    {:ok,
     %{
       email: response["email"],
       first_name: "#{response["middle_name"]} #{response["first_name"]}",
       last_name: response["last_name"],
       birthday: DateTime.parse_date(response["birthday"], "%d/%m/%Y"),
       avatar: response["avatar"]
     }}
  end
end
