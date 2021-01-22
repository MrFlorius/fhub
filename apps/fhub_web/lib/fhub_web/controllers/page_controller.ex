defmodule FhubWeb.PageController do
  use FhubWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
