# Seven-Segment Clock Verilog Module

This is a Verilog module for displaying the time on a seven-segment display. The module takes in a clock signal, reset signal, and button input, and outputs a seven-segment display value and a segment common value. The code is intended to be used on a Zedboard, but can be modified for use on other platforms.

## Installation

To use this Verilog module, simply copy the `top` module into your Verilog project. Make sure to connect the `clk`, `reset_poweron`, `btn`, `seg_data`, and `seg_com` inputs and outputs as described in the code comments.

## Usage

To use the clock module, provide a clock signal to the `clk` input, a reset signal to the `reset_poweron` input, and a button input to the `btn` input. The module will output the current time in seven-segment display format to the `seg_data` output and the segment common value to the `seg_com` output.

## Contributing

If you encounter any issues with this Verilog module or would like to suggest improvements, please feel free to submit an issue or pull request on GitHub.

## License

This code is released under the MIT License. Please see the LICENSE file for more information.
