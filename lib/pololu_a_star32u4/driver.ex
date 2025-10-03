defmodule PololuAStar32u4.Driver do
  @moduledoc """
  Internal GenServer driver for I2C communication with Pololu A-Star 32U4.

  This module handles the low-level I2C protocol communication with the
  A-Star 32U4 board when it's operating in RPi slave mode. It manages
  the persistent I2C connection and implements the board's register-based
  communication protocol.

  The board uses I2C address 0x14 and expects specific register offsets
  for different operations. This module should not be used directly;
  instead use the public API in `PololuAStar32u4`.

  ## I2C Protocol

  - Address: 0x14
  - Bus: "i2c-1"
  - Communication: Write register offset, then read/write data
  - Timing: 1ms delay between operations
  """

  use GenServer
  alias Circuits.I2C
  require Logger

  # I2C configuration
  @i2c_addr 0x14  # A-Star 32U4 I2C slave address
  @i2c_bus "i2c-1"  # Default I2C bus on Raspberry Pi
  @i2c_delay 1  # Delay in milliseconds between I2C operations
  @poll_interval 50  # ms, for button scanning

  @doc """
  Starts the Driver GenServer.

  Initializes the I2C connection to the A-Star 32U4 board.
  This function is called automatically by the Application supervisor.
  """
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc false
  def set_leds(yellow: y, green: g, red: r) do
    GenServer.call(__MODULE__, {:set_leds, y, g, r})
  end

  @doc false
  def read_buttons() do
    GenServer.call(__MODULE__, :read_buttons)
  end

  @doc false
  def subscribe_buttons() do
    GenServer.call(__MODULE__, {:subscribe, self()})
  end

  @doc false
  def set_motors(left: l, right: r) do
    GenServer.call(__MODULE__, {:set_motors, l, r})
  end

  @doc false
  def read_battery_mv() do
    GenServer.call(__MODULE__, :read_battery_mv)
  end

  @doc false
  def read_analog() do
    GenServer.call(__MODULE__, :read_analog)
  end

  @doc false
  def play_song(song) do
    GenServer.call(__MODULE__, {:play_song, song})
  end

  @doc false
  def read_encoders() do
    GenServer.call(__MODULE__, :read_encoders)
  end

  @impl true
  def init(_) do
    case I2C.open(@i2c_bus) do
      {:ok, ref} ->
        Logger.info("PololuAStar32u4.Driver started on bus #{@i2c_bus}")
        :timer.send_interval(@poll_interval, :poll_buttons)
        {:ok, %{ref: ref, buttons: %{a: false, b: false, c: false}, subscribers: [], song_task: nil, stop_flag: false}}
      {:error, reason} ->
        Logger.error("Failed to open I2C bus #{@i2c_bus}: #{inspect(reason)}")
        {:stop, reason}
    end
  end

  @impl true
  def handle_call({:set_leds, y, g, r}, _from, %{ref: ref} = state) do
    write(ref, 0, <<bool(y), bool(g), bool(r)>>)
    {:reply, :ok, state}
  end

  def handle_call(:read_buttons, _from, %{ref: ref} = state) do
    {:ok, <<a, b, c>>} = read(ref, 3, 3)
    {:reply, %{a: a == 1, b: b == 1, c: c == 1}, state}
  end

  def handle_call({:set_motors, l, r}, _from, %{ref: ref} = state) do
    write(ref, 6, <<l::little-signed-16, r::little-signed-16>>)
    {:reply, :ok, state}
  end

  def handle_call(:read_battery_mv, _from, %{ref: ref} = state) do
    {:ok, <<mv::little-unsigned-16>>} = read(ref, 10, 2)
    {:reply, mv, state}
  end

  def handle_call(:read_analog, _from, %{ref: ref} = state) do
    {:ok, bin} = read(ref, 12, 12)
    values = for <<v::little-unsigned-16 <- bin>>, do: v
    {:reply, values, state}
  end

  def handle_call({:subscribe, pid}, _from, state) do
    Process.monitor(pid)
    {:reply, :ok, %{state | subscribers: [pid | state.subscribers]}}
  end

  def handle_call(:read_encoders, _from, %{ref: ref} = state) do
    {:ok, <<l::little-signed-16, r::little-signed-16>>} = read(ref, 39, 4)
    {:reply, {l, r}, state}
  end

  def handle_call(:stop_flag?, _from, %{stop_flag: flag} = state),
    do: {:reply, flag, state}

  @impl true
  def handle_cast({:play_song, song}, %{ref: ref, song_task: nil} = state) do
    task = Task.start(fn -> do_play_song(ref, song, self()) end) |> elem(1)
    {:noreply, %{state | song_task: task, stop_flag: false}}
  end

  def handle_cast(:stop_song, %{ref: ref, song_task: task} = state) when not is_nil(task) do
    Logger.info("Stopping song playback…")
    payload = <<0>> <> String.duplicate(<<0>>, 14)
    write(ref, 24, payload)
    {:noreply, %{state | stop_flag: true}}
  end

  def handle_cast(:stop_song, state), do: {:noreply, state}

  defp do_play_song(ref, song, parent) do
    chunks =
      String.codepoints(song)
      |> Enum.chunk_every(14)
      |> Enum.map(&Enum.join/1)

    Enum.each(chunks, fn chunk ->
      if GenServer.call(__MODULE__, :stop_flag?) do
        {:halt, :stopped}
      else
        play_notes(ref, chunk)
        wait_until_done(ref)
        {:cont, :ok}
      end
    end)

    send(parent, :song_finished)
  end

  defp read(ref, offset, size) do
    :ok = I2C.write(ref, @i2c_addr, <<offset>>)
    Process.sleep(@i2c_delay)
    I2C.read(ref, @i2c_addr, size)
  end

  defp write(ref, offset, payload) do
    :ok = I2C.write(ref, @i2c_addr, [offset | :binary.bin_to_list(payload)])
    Process.sleep(@i2c_delay)
    :ok
  end

  defp play_notes(ref, notes) do
    notes_bin = String.pad_trailing(notes, 14, <<0>>)
    write(ref, 24, <<1, notes_bin::binary-size(14)>>)
  end

  defp wait_until_done(ref) do
    Process.sleep(20)
    case read_flag(ref) do
      false -> :ok
      true -> wait_until_done(ref)
    end
  end

  defp read_flag(ref) do
    {:ok, <<flag>>} = read(ref, 24, 1)
    flag == 1
  end

  defp bool(true), do: 1
  defp bool(false), do: 0
end
