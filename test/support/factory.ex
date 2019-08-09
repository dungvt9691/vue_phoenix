defmodule VuePhoenix.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: VuePhoenix.Repo

  alias VuePhoenix.Identify.{Token, User}

  def user_factory do
    %User{
      email: Faker.Internet.email(),
      password: Faker.String.base64()
    }
  end

  def token_factory do
    %Token{
      code: Faker.String.base64(100)
    }
  end
end
