defmodule VuePhoenix.Factory do
  use ExMachina.Ecto, repo: VuePhoenix.Repo

  alias VuePhoenix.{User, Token}

  def user_factory do
    %User{
      email: "dungvt9691@gmail.com",
      password: "password"
    }
  end

  def token_factory do
    %Token{
      code: "code"
    }
  end
end
