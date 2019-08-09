defmodule VuePhoenix.Image do
  @moduledoc false

  use Arc.Definition
  use Arc.Ecto.Definition

  def __storage, do: Arc.Storage.Local

  # Include ecto support (requires package arc_ecto installed):
  # use Arc.Ecto.Definition

  @versions [:original, :s500x, :s250x, :s50x, :s500x500, :s250x250, :s50x50]

  # To add a thumbnail version:
  # @versions [:original, :thumb]

  # Override the bucket on a per definition basis:
  # def bucket do
  #   :custom_bucket_name
  # end

  # Whitelist file extensions:
  def validate({file, _}) do
    ~w(.jpg .jpeg .gif .png) |> Enum.member?(Path.extname(file.file_name))
  end

  # Define a thumbnail transformation:
  def transform(:s500x, _) do
    {:convert, "-strip -geometry 500x -format png", :png}
  end

  def transform(:s250x, _) do
    {:convert, "-strip -geometry 250x -format png", :png}
  end

  def transform(:s50x, _) do
    {:convert, "-strip -geometry 50x -format png", :png}
  end

  def transform(:s500x500, _) do
    {:convert, "-strip -thumbnail 500x500^ -gravity center -extent 500x500 -format png", :png}
  end

  def transform(:s250x250, _) do
    {:convert, "-strip -thumbnail 250x250^ -gravity center -extent 250x250 -format png", :png}
  end

  def transform(:s50x50, _) do
    {:convert, "-strip -thumbnail 50x50^ -gravity center -extent 50x50 -format png", :png}
  end

  # Override the persisted filenames:
  def filename(_version, {_file, scope}) do
    id =
      scope.id
      |> Integer.to_string()
      |> String.pad_leading(8, "0")

    "IMG#{id}"
  end

  # Override the storage directory:
  def storage_dir(version, _) do
    if Mix.env() == :test do
      "uploads/test/images/#{version}"
    else
      "uploads/images/#{version}"
    end
  end

  # Provide a default URL if there hasn't been a file uploaded
  # def default_url(version, scope) do
  #   "/images/avatars/default_#{version}.png"
  # end

  # Specify custom headers for s3 objects
  # Available options are [:cache_control, :content_disposition,
  #    :content_encoding, :content_length, :content_type,
  #    :expect, :expires, :storage_class, :website_redirect_location]
  #
  # def s3_object_headers(version, {file, scope}) do
  #   [content_type: MIME.from_path(file.file_name)]
  # end
end
