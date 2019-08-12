defmodule VuePhoenix.Services.Encryption do
  @moduledoc false

  alias Comeonin.Bcrypt
  alias VuePhoenix.Identify.User

  def hash_password(password), do: Bcrypt.hashpwsalt(password)

  def validate_password(%User{} = user, password), do: Bcrypt.check_pass(user, password)
end
