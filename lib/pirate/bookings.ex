defmodule Pirate.Bookings do
  @default_paginate_params %{
    "page_number" => 1,
    "page_length" => 20
  }

  def list_parsed_data do
    if Mix.env() == :test do
      File.read!("test/support/test_data.json")
    else
      File.read!("data.json")
    end
    |> Jason.decode!()
  end

  @doc """
  Returns the requested page of results
  """
  def list_booked_bookings(params) do
    params = build_paginate_params(params)
    page_index = params.page_number - 1

    paginated =
      list_parsed_data()
      |> Enum.chunk_every(params.page_length)

    results = Enum.at(paginated, page_index) || []

    %{
      results: results,
      pages: length(paginated),
      page_number: page_index + 1
    }
  end

  defp build_paginate_params(params) do
    %{
      "page_number" => page_number,
      "page_length" => page_length
    } = Map.merge(@default_paginate_params, params)

    %{
      page_number: to_integer(page_number),
      page_length: to_integer(page_length)
    }
  end

  defp to_integer(string) when is_binary(string), do: String.to_integer(string)
  defp to_integer(integer) when is_integer(integer), do: integer

  @doc """
  Returns percentage (represented by decimal) of time that
  each studio has been booked for from it's first booked day of operation
  """
  def list_studio_stats() do
    accumulator = %{
      earliest: nil,
      latest: nil,
      seconds_by_studio: %{}
    }

    accumulated =
      list_parsed_data()
      |> Enum.reduce(accumulator, &reduce_stats/2)

    total_time = DateTime.diff(accumulated.latest, accumulated.earliest)

    %{
      total_time: total_time,
      stats_from: DateTime.to_iso8601(accumulated.earliest),
      stats_to: DateTime.to_iso8601(accumulated.latest),
      stats_by_studio:
        Map.new(accumulated.seconds_by_studio, fn {studio_id, total_seconds} ->
          {studio_id,
           total_seconds
           |> Decimal.div(total_time)
           |> Decimal.round(5)
           |> Decimal.to_float()}
        end)
    }
  end

  def reduce_stats(
        %{
          "studioId" => studio_id,
          "startsAt" => starts_at_str,
          "endsAt" => ends_at_str
        },
        accumulator
      ) do
    {:ok, starts_at, 0} = DateTime.from_iso8601(starts_at_str)
    {:ok, ends_at, 0} = DateTime.from_iso8601(ends_at_str)

    booking_duration = DateTime.diff(ends_at, starts_at)

    seconds_by_studio =
      Map.update(
        accumulator.seconds_by_studio,
        studio_id,
        booking_duration,
        &(&1 + booking_duration)
      )

    accumulator
    |> Map.update!(:earliest, &take_earliest(&1, starts_at))
    |> Map.update!(:latest, &take_latest(&1, ends_at))
    |> Map.put(:seconds_by_studio, seconds_by_studio)
  end

  defp take_earliest(nil, dt2), do: dt2

  defp take_earliest(dt1, dt2) do
    if DateTime.compare(dt1, dt2) == :lt do
      dt1
    else
      dt2
    end
  end

  defp take_latest(nil, dt2), do: dt2

  defp take_latest(dt1, dt2) do
    if DateTime.compare(dt1, dt2) == :gt do
      dt1
    else
      dt2
    end
  end
end
