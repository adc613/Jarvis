defmodule ConsoleWeb.DoorbellController do
  defmodule LightState do
    @type t :: %LightState{
      on: boolean,
      sat: integer,
      bri: integer,
      hue: integer,
    }

    defstruct [:on, :sat, :bri, :hue]
  end


  use ConsoleWeb, :controller

  def test(conn, _params) do 
    get_light_state() |> render_state(conn)
  end

  def ring_doorbell(conn, _params) do 
    case ring(conn, :s0) do
      :ok ->
        ring(conn, :s1)
      :error ->
        ring(conn, :error)
    end
  end

  defp ring(conn, :s0) do
    Process.sleep(1000)
    case set_light_state(true) do
      :ok ->
        ring(conn, :s2)
      :error ->
        ring(conn, :error)
    end
  end

  defp ring(conn, :s1) do
    Process.sleep(1000)
    case set_light_state(true) do
      :ok ->
        ring(conn, :s2)
      :error ->
        ring(conn, :error)
    end
  end

  defp ring(conn, :s2) do
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
        body |> Poison.decode! |> decode_light_state
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

  defp render_state(light_state, conn) do
    conn |> render(ConsoleWeb.DoorbellView, "test.json", light_state)
  end

  defp decode_light_state(body) do
    on = body["state"]["on"]
    sat = body["state"]["sat"]
    bri = body["state"]["bri"]
    hue = body["state"]["hue"]
    %LightState{on: on, sat: sat, bri: bri, hue: hue}
  end
end
