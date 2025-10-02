defmodule PololuAStar32u4 do
  @moduledoc """
  Public interface for controlling the Pololu A-Star 32U4 board
  when operating in RPi slave mode.

  This library provides an Elixir interface for communicating with
  the Pololu A-Star 32U4 board via I2C. It allows controlling LEDs,
  motors, reading sensors and buttons, and playing melodies when the
  board is in RPi slave mode.
  """

  alias PololuAStar32u4.Driver

  @doc """
  Controls the state of the LEDs.

  ## Parameters

  - `yellow`: State of the yellow LED (true/false)
  - `green`: State of the green LED (true/false)
  - `red`: State of the red LED (true/false)

  ## Examples

      iex> PololuAStar32u4.set_leds(yellow: true, green: false, red: true)
      :ok
  """
  def set_leds(opts) do
    Driver.set_leds(opts)
  end

  @doc """
  Reads the state of the buttons.

  ## Returns

  Returns a map with the state of buttons A, B and C.

  ## Examples

      iex> PololuAStar32u4.read_buttons()
      %{a: false, b: true, c: false}
  """
  def read_buttons do
    Driver.read_buttons()
  end

  @doc """
  Controls the speed of the motors.

  ## Parameters

  - `left`: Speed of the left motor (-400 to 400)
  - `right`: Speed of the right motor (-400 to 400)

  ## Examples

      iex> PololuAStar32u4.set_motors(left: 200, right: -100)
      :ok
  """
  def set_motors(opts) do
    Driver.set_motors(opts)
  end

  @doc """
  Reads the battery voltage in millivolts.

  ## Examples

      iex> PololuAStar32u4.read_battery_mv()
      11700
  """
  def read_battery_mv do
    Driver.read_battery_mv()
  end

  @doc """
  Reads the analog values from all channels.

  ## Returns

  Returns a list of 6 analog values (0-1023).

  ## Examples

      iex> PololuAStar32u4.read_analog()
      [512, 0, 1023, 256, 768, 100]
  """
  def read_analog do
    Driver.read_analog()
  end

  @doc """
  Plays a melody.

  ## Parameters

  - `song`: String containing the notes to play

  ## Examples

      iex> PololuAStar32u4.play_song("c4e4g4c5")
      :ok
  """
  def play_song(song) do
    Driver.play_song(song)
  end

  @doc """
  Reads the motor encoder values.

  ## Returns

  Returns a tuple {left_encoder, right_encoder}.

  ## Examples

      iex> PololuAStar32u4.read_encoders()
      {1250, -800}
  """
  def read_encoders do
    Driver.read_encoders()
  end
end
