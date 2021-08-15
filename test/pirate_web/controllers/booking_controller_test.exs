defmodule PirateWeb.BookingControllerTest do
  use PirateWeb.ConnCase

  @paginate_params %{
    page_number: 1,
    page_length: 2
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists paginated bookings", %{conn: conn} do
      conn = get(conn, Routes.booking_path(conn, :index), params: @paginate_params)

      assert %{
               "page_number" => 1,
               "pages" => 6,
               "results" => results
             } = json_response(conn, 200)

      assert length(results) == 2

      [
        %{
          "endsAt" => "2020-09-11T06:00:00.000Z",
          "startsAt" => "2020-09-11T03:00:00.000Z",
          "studioId" => 1
        }
        | _rest
      ] = results
    end
  end

  describe "stats" do
    test "returns stats by studio", %{conn: conn} do
      conn = get(conn, Routes.booking_path(conn, :stats))

      assert %{
               "stats_by_studio" => %{"1" => 0.16216, "2" => 0.22973},
               "stats_from" => "2020-09-11T03:00:00.000Z",
               "stats_to" => "2020-09-14T05:00:00.000Z",
               "total_time" => 266_400
             } = json_response(conn, 200)
    end
  end
end
