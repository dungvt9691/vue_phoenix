defmodule VuePhoenix.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: VuePhoenix.Repo

  alias VuePhoenix.Identify.{Token, User}
  alias VuePhoenix.Social.{Comment, Image, Post}

  def user_factory do
    %User{
      email: Faker.Internet.email(),
      password: Faker.String.base64(),
      reset_password_token: Faker.String.base64()
    }
  end

  def token_factory do
    %Token{
      code: Faker.String.base64(100)
    }
  end

  def post_factory do
    %Post{
      content: Faker.Lorem.paragraph()
    }
  end

  def image_factory do
    %Image{}
  end

  def comment_factory do
    %Comment{
      content: Faker.Lorem.paragraph()
    }
  end
end
