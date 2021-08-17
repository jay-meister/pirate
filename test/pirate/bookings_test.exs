defmodule Pirate.BookingsTest do
  use ExUnit.Case

  @test_params %{
    "page_number" => 1,
    "page_length" => 5
  }

  alias Pirate.Bookings

  describe "list_booked_bookings" do
    test "uses default pagination of 20 results per page" do
      assert %{
               pages: 1,
               page_number: 1,
               results: results
             } = Bookings.list_booked_bookings(%{})

      assert length(results) == 11
    end

    test "page_length can be altered" do
      params = @test_params

      assert %{
               pages: 3,
               page_number: 1,
               results: results
             } = Bookings.list_booked_bookings(params)

      assert length(results) == 5

      assert [
               %{
                 "studioId" => 1,
                 "startsAt" => "2020-09-11T03:00:00.000Z",
                 "endsAt" => "2020-09-11T06:00:00.000Z"
               }
               | _rest
             ] = results
    end

    test "page_number can be specified" do
      params = %{@test_params | "page_number" => 2}

      assert %{
               pages: 3,
               page_number: 2,
               results: results
             } = Bookings.list_booked_bookings(params)

      assert length(results) == 5

      assert [
               %{
                 "studioId" => 2,
                 "startsAt" => "2020-09-12T19:00:00.000Z",
                 "endsAt" => "2020-09-12T22:00:00.000Z"
               }
               | _rest
             ] = results
    end

    test "final page returns correct number of results" do
      params = %{@test_params | "page_number" => 3}

      assert %{
               pages: 3,
               page_number: 3,
               results: [
                 %{
                   "studioId" => 2,
                   "startsAt" => "2020-09-14T01:00:00.000Z",
                   "endsAt" => "2020-09-14T05:00:00.000Z"
                 }
               ]
             } = Bookings.list_booked_bookings(params)
    end

    test "if page does not exist, empty list of results is returned" do
      params = %{@test_params | "page_number" => 4}

      assert %{
               pages: 3,
               page_number: 4,
               results: []
             } = Bookings.list_booked_bookings(params)
    end
  end

  describe "list_studio_stats" do
    test "returns map with stats_by_studio map as well as earliest start and latest end" do
      assert %{
               stats_from: "2020-09-11T03:00:00.000Z",
               stats_to: "2020-09-14T05:00:00.000Z",
               stats_by_studio: %{}
             } = Bookings.list_studio_stats()
    end
  end

  describe "do_list_studio_stats - stats_by_studio calculation" do
    test "handles empty data" do
      data = []

      assert %{
               stats_from: nil,
               stats_to: nil,
               stats_by_studio: nil
             } = Bookings.do_list_studio_stats(data)
    end

    test "returns 1.0 if studio booked for 100% of time" do
      data = [
        %{
          "studioId" => 1,
          "startsAt" => "2020-09-11T03:00:00.000Z",
          "endsAt" => "2020-09-11T06:00:00.000Z"
        }
      ]

      assert %{
               stats_from: "2020-09-11T03:00:00.000Z",
               stats_to: "2020-09-11T06:00:00.000Z",
               stats_by_studio: %{1 => 1.0}
             } = Bookings.do_list_studio_stats(data)
    end

    test "returns 0.5 if studio booked for 50% of time" do
      data = [
        %{
          "studioId" => 1,
          "startsAt" => "2020-09-11T03:00:00.000Z",
          "endsAt" => "2020-09-11T06:00:00.000Z"
        },
        %{
          "studioId" => 2,
          "startsAt" => "2020-09-11T03:00:00.000Z",
          "endsAt" => "2020-09-11T04:30:00.000Z"
        }
      ]

      assert %{
               stats_from: "2020-09-11T03:00:00.000Z",
               stats_to: "2020-09-11T06:00:00.000Z",
               stats_by_studio: %{1 => 1.0, 2 => 0.5}
             } = Bookings.do_list_studio_stats(data)
    end
  end
end
