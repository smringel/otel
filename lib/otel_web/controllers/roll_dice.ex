defmodule OtelWeb.DiceController do
  use OtelWeb, :controller
  use OpenTelemetryDecorator

  @decorate with_span("DiceController.roll")
  def roll(conn, _params) do
    send_resp(conn, 200, roll_dice())
  end

  defp roll_dice() do
    roll = Enum.random(1..6)
    OpenTelemetry.Tracer.set_attribute("dice_roll", roll)

    to_string(roll)
  end
end
