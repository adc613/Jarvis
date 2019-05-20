defmodule ConsoleWeb.DoorbellController do
  use ConsoleWeb, :controller

  def test(conn, _params) do 
    case set_light_state(false) do
      :ok ->
        get_light_state()
        |> test_render(conn)
      :error ->
        test_render(:error, conn)
    end
  end

  def ring_doorbell(conn, _params) do 
    case set_light_state(false) do
      :ok ->
        ring(conn, :stage1)
      :error ->
        ring(conn, :error)
    end
  end

  defp ring(conn, :stage1) do
    Process.sleep(1000)
    case set_light_state(true) do
      :ok ->
        ring(conn, :stage2)
      :error ->
        ring(conn, :error)
    end
  end

  defp ring(conn, :stage2) do
    get_light_state()
    |> test_render(conn)
  end

  defp ring(conn, :error) do
    test_render(:error, conn)
  end

  defp ring(conn, :ok) do
    test_render(:error, conn)
    get_light_state()
    |> test_render(conn)
  end

  defp get_light_state() do
    case HTTPoison.get "192.168.70.116/api/wLGFA5G9qHCmuthlGDMFQHZcEqR11TtfeVGOWtjU/lights/7" do
      {:ok, %HTTPoison.Response{body: body}} ->
        body
        |> Poison.decode!
        |> (&(&1["state"]["on"])).()
      {:error} ->
        :error
    end
  end

  defp set_light_state(state) do
    json = Poison.encode!(%{on: state})
    case HTTPoison.put "192.168.70.116/api/wLGFA5G9qHCmuthlGDMFQHZcEqR11TtfeVGOWtjU/lights/7/state", json do
      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        get_light_state()
        body |> is_ok
      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        :error
      {:error} ->
        :error
    end
  end

  defp is_ok(body) do
    case Poison.decode!(body) do
      [resp|_tail]  ->
        case resp["error"] do
          nil ->
            :ok
          _ ->
            :error
        end
      _ ->
        :error
    end
  end

  defp test_render(true, conn) do
    conn
    |> render(ConsoleWeb.DoorbellView, "test.json", state: :on)
  end

  defp test_render(false, conn) do
    conn
    |> render(ConsoleWeb.DoorbellView, "test.json", state: :off)
  end

  defp test_render(:error, conn) do
    conn
    |> render(ConsoleWeb.DoorbellView, "test.json", state: :error)
  end

  defp test_render(_uknown, conn) do
    conn
    |> render(ConsoleWeb.DoorbellView, "test.json", state: :uknown)
  end
end
