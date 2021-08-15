defmodule PirateWeb.BookingController do
  use PirateWeb, :controller

  alias Pirate.Bookings

  def index(conn, %{"params" => paginate_params}) do
    bookings = Bookings.list_booked_bookings(paginate_params)

    render(conn, "index.json", bookings: bookings)
  end

  def stats(conn, _params) do
    studio_stats = Bookings.list_studio_stats()

    render(conn, "studio_stats.json", studio_stats: studio_stats)
  end
end
