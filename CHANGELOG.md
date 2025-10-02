# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-10-02

### Added
- Initial release of Pololu A-Star 32U4 Elixir library
- LED control (yellow, green, red)
- Button reading (A, B, C)
- Motor control with speed values (-400 to 400)
- Battery voltage monitoring in millivolts
- Analog sensor reading (6 channels, 0-1023)
- Audio melody playback
- Motor encoder reading
- I2C communication via Circuits.I2C
- GenServer-based driver architecture
- Comprehensive API documentation
- Livebook testing examples

### Technical Details
- I2C address: 0x14
- Default I2C bus: "i2c-1"
- Automatic application startup
- Register-based communication protocol
- 1ms delay between I2C operations