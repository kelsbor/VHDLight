# VHDLight

A simple VHDL learning project that implements a smart lighting system with a single push-button control and an ambient light sensor.

## Project Goal

The main goal of this project is to learn and apply VHDL concepts to create a real-world application. The project focuses on digital logic design, finite state machines, and timing circuits.

## Functionality

The system controls the brightness of a light source through a single push-button. It has three main states:

*   **Off:** The light is turned off.
*   **Half Light:** The light is at 50% brightness.
*   **Full Light:** The light is at 100% brightness.

The user can cycle through these states using the push-button:

*   **Short Press:** A short press of the button will turn the light on (to Full Light) if it's off, or turn it off if it's on.
*   **Long Press:** A long press of the button will switch between Full Light and Half Light.

The system also includes a simulated ambient light sensor:

*   **Dark Environment:** If the sensor detects a dark environment, it will automatically turn the light on to Full Light.
*   **Bright Environment:** If the sensor detects a bright environment, it will automatically turn the light off.

The user can always override the automatic control with the push-button.

## Project Structure

The project is divided into the following VHDL modules:

*   `projeto_top.vhd`: The top-level entity that connects all the other modules.
*   `fsm_iluminacao.vhd`: A finite state machine that controls the lighting states based on the user input and the ambient light sensor.
*   `click_timer.vhd`: A timer to differentiate between short and long button presses.
*   `debouncer.vhd`: A circuit to eliminate mechanical bounces from the push-button.
*   `pwm_generator.vhd`: A PWM generator to control the brightness of the LED.
*   `tick_generator.vhd`: A clock divider to generate the necessary clock signals for the other modules.

## Implementation

 The `projeto_top.vhd` file connects all the components and maps the inputs and outputs to the FPGA pins. The simulation files are in the `sim` directory.
