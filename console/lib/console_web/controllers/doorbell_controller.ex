defmodule ConsoleWeb.DoorbellController do

  use ConsoleWeb, :controller
  @hue_user "wLGFA5G9qHCmuthlGDMFQHZcEqR11TtfeVGOWtjU"
  @enabled_lights [id: "7", id: "3"]
  @force_enabled_lights [id: "8"]
  @alert_hue 46920
  @alert_time 2500


  defmodule LightState do
    @type t :: %LightState{
      on: boolean,
      sat: integer,
      bri: integer,
      hue: integer,
    }

    defstruct [:on, :sat, :bri, :hue]
  end


  def test(conn, _params) do 
    initial_state = get_light_state("7") 

    render_state(initial_state, conn)
  end

  def ring_doorbell(conn, _params) do 
    initial_state = get_light_state("7") 

    all_lights = @enabled_lights ++ @force_enabled_lights

    init_values =
      Keyword.get_values(all_lights, :id)
      |> Enum.map(fn id -> [id, get_light_state(id)] end)

    Keyword.get_values(@enabled_lights, :id)
      |> Enum.map(fn id -> [id, get_light_state(id)] end)
      |> Enum.map(fn [id, state] -> [id, %{state | hue: @alert_hue}] end)
      |> Enum.each(fn x -> set_light_state(x) end)

    Keyword.get_values(@force_enabled_lights, :id)
      |> Enum.map(fn id -> [id, get_light_state(id)] end)
      |> Enum.map(fn [id, state] -> [id, %{state | on: true, bri: 255, sat: 255, hue: @alert_hue}] end)
      |> Enum.each(fn x -> set_light_state(x) end)

    Process.sleep(@alert_time)

    init_values
    |> Enum.each(fn x -> set_light_state(x) end)

    render_state(initial_state, conn)
  end


  defp get_light_state(id) do
    url = "192.168.70.116/api/" <> @hue_user <> "/lights/" <> id

    case HTTPoison.get url do
      {:ok, %HTTPoison.Response{body: body}} ->
        body |> Poison.decode! |> decode_light_state
      {:error} ->
        :error
    end
  end

  defp set_light_state([id, state]) do
    url =  "192.168.70.116/api/" <> @hue_user <> "/lights/" <>  id <> "/state"

    response = 
      state
      |> Poison.encode!
      |> (&(HTTPoison.put &2, &1)).(url)

    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
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
