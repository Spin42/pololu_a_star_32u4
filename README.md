# Pololu A-Star 32U4 - Elixir Library

[![Hex.pm](https://img.shields.io/hexpm/v/pololu_a_star_32u4.svg)](https://hex.pm/packages/pololu_a_star_32u4)
[![Documentation](https://img.shields.io/badge/docs-hexdocs-blue.svg)](https://hexdocs.pm/pololu_a_star_32u4)

An Elixir library for controlling the [Pololu A-Star 32U4](https://www.pololu.com/category/149/a-star-32u4-programmable-controllers) board when operating in RPi slave mode via I2C communication.

## Features

- 🚦 **LED Control** - Control yellow, green, and red LEDs
- 🎮 **Button Reading** - Read states of buttons A, B, and C
- 🚗 **Motor Control** - Control left and right motors with speed values
- 🔋 **Battery Monitoring** - Read battery voltage in millivolts
- 📊 **Analog Sensors** - Read 6 analog input channels (0-1023)
- 🎵 **Audio** - Play melodies using note strings
- 📏 **Encoders** - Read motor encoder values

## Installation

Add `pololu_a_star_32u4` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:pololu_a_star_32u4, "~> 0.1.0"}
  ]
end
```

## Hardware Setup

1. **A-Star 32U4 Board**: Flash the [RPi slave firmware](https://github.com/pololu/pololu-rpi-slave-arduino-library/blob/master/examples/AStarRPiSlaveDemo/AStarRPiSlaveDemo.ino) to your A-Star 32U4
2. **I2C Connection**: Connect the board to your Raspberry Pi

3. **I2C Enable**: Ensure I2C is enabled on your Raspberry Pi device

## Quick Start

```elixir
# Control LEDs
PololuAStar32u4.set_leds(yellow: true, green: false, red: false)

# Read buttons
buttons = PololuAStar32u4.read_buttons()
# => %{a: false, b: true, c: false}

# Control motors (speed: -400 to 400)
PololuAStar32u4.set_motors(left: 200, right: 200)

# Read battery voltage
battery_mv = PololuAStar32u4.read_battery_mv()
# => 11700 (11.7V)

# Read analog sensors
analog = PololuAStar32u4.read_analog()
# => [512, 0, 1023, 256, 768, 100]

# Play a melody
PololuAStar32u4.play_song("c4e4g4c5")

# Read motor encoders
{left, right} = PololuAStar32u4.read_encoders()
# => {1250, -800}
```

## Livebook Integration

For interactive development and testing, use the included Livebook:

1. Open `livebook_test.livemd` in Livebook
2. Run the cells to test different functions
3. Monitor your robot's sensors in real-time

## API Reference

### LED Control

```elixir
PololuAStar32u4.set_leds(yellow: boolean, green: boolean, red: boolean)
```

### Button Reading

```elixir
PololuAStar32u4.read_buttons()
# Returns: %{a: boolean, b: boolean, c: boolean}
```

### Motor Control

```elixir
PololuAStar32u4.set_motors(left: integer, right: integer)
# Speed range: -400 to 400
```

### Sensor Reading

```elixir
# Battery voltage in millivolts
PololuAStar32u4.read_battery_mv()

# Analog sensors (6 channels, 0-1023)
PololuAStar32u4.read_analog()

# Motor encoders
PololuAStar32u4.read_encoders()
```

### Audio

```elixir
PololuAStar32u4.play_song("c4e4g4c5")
```

## I2C Protocol Details

The library implements the A-Star 32U4 RPi slave protocol:

- **Address**: 0x14
- **Bus**: i2c-1 (default)
- **Protocol**: Write register offset, then read/write data
- **Timing**: 1ms delay between operations

### Register Map

| Offset | Size | Function |
|--------|------|----------|
| 0      | 3    | LEDs (yellow, green, red) |
| 3      | 3    | Buttons (A, B, C) |
| 6      | 4    | Motors (left, right - 16-bit signed) |
| 10     | 2    | Battery voltage (16-bit unsigned) |
| 12     | 12   | Analog readings (6 × 16-bit unsigned) |
| 24     | 15   | Buzzer (flag + 14 chars) |
| 39     | 4    | Encoders (left, right - 16-bit signed) |

## Error Handling

The library includes robust error handling:

- I2C connection failures are logged and reported
- Graceful degradation when hardware is unavailable
- Configurable auto-start for development environments

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -am 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Pololu A-Star 32U4 Robot controller](https://www.pololu.com/docs/0J66) for the A-Star 32U4 board
- [Circuits.I2C](https://hex.pm/packages/circuits_i2c) for I2C communication
