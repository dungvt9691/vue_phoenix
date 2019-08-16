defmodule VuePhoenix.Services.SendMail do
  @moduledoc false
  import Bamboo.Email
  use Bamboo.Phoenix, view: VuePhoenixWeb.EmailView

  @default_from "<Vue Phoenix your-gmail-account@gmail.com>"

  def reset_password_instructions(user) do
    base_email()
    |> to(user.email)
    |> subject("Reset password instructions")
    |> assign(:user, user)
    |> render("reset_password_instructions.html")
  end

  defp base_email do
    new_email()
    # Set a default from
    |> from(System.get_env("SMTP_FROM") || @default_from)
    # Set default layout
    |> put_html_layout({VuePhoenixWeb.LayoutView, "email.html"})
  end
end
