defmodule FlyWeb.AppLive.Show do
  use FlyWeb, :live_view
  require Logger

  alias Fly.Client
  alias FlyWeb.Components.HeaderBreadcrumbs

  @app_refresh_rate 5_000

  @impl true
  def mount(%{"name" => name}, session, socket) do
    socket =
      assign(socket,
        config: client_config(session),
        state: :loading,
        app: nil,
        app_name: name,
        count: 0,
        authenticated: true
      )

    # Only make the API call if the websocket is setup. Not on initial render.
    if connected?(socket) do
      send(self(), :refresh_app)

      {:ok, socket}
    else
      {:ok, socket}
    end
  end

  defp client_config(session) do
    Fly.Client.config(access_token: session["auth_token"] || System.get_env("FLYIO_ACCESS_TOKEN"))
  end

  defp fetch_app(socket) do
    app_name = socket.assigns.app_name

    case Client.fetch_app(app_name, socket.assigns.config) do
      {:ok, app} ->
        assign(socket, :app, app)

      {:error, :unauthorized} ->
        put_flash(socket, :error, "Not authenticated")

      {:error, reason} ->
        Logger.error("Failed to load app '#{inspect(app_name)}'. Reason: #{inspect(reason)}")

        put_flash(socket, :error, reason)
    end
  end

  @impl true
  def handle_event("click", _params, socket) do
    {:noreply, assign(socket, count: socket.assigns.count + 1)}
  end

  @impl true
  def handle_info(:refresh_app, socket) do
    socket = fetch_app(socket)

    Process.send_after(self(), :refresh_app, @app_refresh_rate)

    {:noreply, socket}
  end

  def allocation_health_description(instance) do
    checks = [
      {instance["totalCheckCount"], "total"},
      {instance["passingCheckCount"], "passing"},
      {instance["warningCheckCount"], "warning"},
      {instance["criticalCheckCount"], "critical"}
    ]

    checks
    |> Enum.reject(fn {count, _} -> count == 0 end)
    |> Enum.map(fn {count, type} -> "#{count} #{type}" end)
    |> Enum.join(", ")
  end

  def deployment_instances_description(%{"deploymentStatus" => deployment_status}) do
    "#{deployment_status["desiredCount"]} desired,\
    #{deployment_status["placedCount"]} placed,\
    #{deployment_status["healthyCount"]} healthy,\
    #{deployment_status["unhealthyCount"]} unhealthy"
  end

  def status_bg_color(app) do
    case app["status"] do
      "running" -> "bg-green-100"
      "dead" -> "bg-red-100"
      _ -> "bg-yellow-100"
    end
  end

  def status_text_color(app) do
    case app["status"] do
      "running" -> "text-green-800"
      "dead" -> "text-red-800"
      _ -> "text-yellow-800"
    end
  end

  def preview_url(app) do
    "https://#{app["name"]}.fly.dev"
  end
end
