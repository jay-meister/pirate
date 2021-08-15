defmodule PirateWeb.BookingView do
  use PirateWeb, :view

  def render("index.json", %{bookings: bookings}) do
    bookings
    |> Map.take([
      :page_number,
      :pages,
      :results
    ])
  end

  def render("studio_stats.json", %{studio_stats: studio_stats}) do
    studio_stats
    |> Map.take([
      :total_time,
      :stats_from,
      :stats_to,
      :stats_by_studio
    ])
  end
end
