# Configurable multi-channel Pulse Width Modulation (PWM) for LED brightness control

### Team members

* Vojtěch Smejkal -  Designed the main top-level architecture and completed the overall project. Implemented the PWM generator and top-level integration.
* Polák Tomáš - Developed the debouncer, intensity control, and channel selector. Also created the project video.
* Matúš Repáš - Implemented the bar graph and 7-segment display, designed the top-level schematic, and edited the README file.

* Even though these were our main individual contributions, the entire project was completed as a team effort.

### Abstract

This project presents a configurable multi-channel Pulse Width Modulation (PWM) system designed for precise LED brightness control. The system allows users to adjust the brightness of multiple LEDs independently by varying duty cycles across several PWM channels. A flexible interface enables easy reconfiguration of parameters such as frequency, duty cycle, and channel count, making the design adaptable to various lighting applications. Emphasis is placed on achieving smooth brightness transitions and minimizing flicker through optimized PWM signal generation. Overall, this configurable PWM solution offers a scalable, customizable method for efficient LED brightness management in diverse environments.

The main contributions of the project are:

* Implementation of a PWM signal generator with adjustable duty cycle, controlled using FPGA pushbuttons.

* Design of a user interface using five onboard buttons (BTNR, BTNL, BTND, BTNU, BTNC) for PWM adjustment, channel selection, and reset functionality.

* Development of a bar graph display and 7-segment display to visually represent PWM signal parameters.

* Creation of a debouncing system to ensure reliable input from physical buttons.

* Integration of multiple modules into a top-level design, including signal routing and synchronization.

* Utilization of limited Pmod ports by distributing I/O between external LEDs and a BAR display, demonstrating efficient hardware resource management.

* Complete team collaboration, including system design, coding, simulation, schematic design, README preparation, and video/poster presentation.

## Hardware description of demo application
The FPGA board uses five buttons: BTNR, BTNL, BTND, BTNU, and BTNC. BTNR and BTNL control the duty cycle of the PWM signal, while BTND and BTNU are used to switch between different PWM outputs. BTNC serves as the central reset button, which restores the PWM settings to default, setting the duty cycle back to 50%.

For input/output, we utilize four pins from the JA Pmod port on the FPGA. Two pins are connected to external LEDs, and the remaining two are used for the BAR segment display. This configuration was necessary because the JB Pmod port, which is our primary interface, did not have enough available pins for the BAR segment display. Other pwm signals are send to onboard leds to controll their brightness.

### Pmod Ports
![pmod](imgs/Pmod_pinout.png)

### Schematic
![schema](imgs/schema_toplevel.png)

## Software description

The entire system can be divided into six main functional blocks: bar_graph, channel_selector, debouncer, intensity_controll, pwm_generator, seg7disp. Each block is responsible for a distinct part of the device's functionality.

* debouncer: To ensure stable and noise-free button inputs, this module filters out any signal bouncing from the physical buttons. It is used to stabilize inputs for both the intensity and channel controls.

* channel_selector: This module enables switching between different PWM channels, allowing the user to cycle through and control multiple signals individually.

* seg7disp: This module manages the 7-segment display, showing numeric values such as the current PWM channel.

* intensity_control: Connected to the button inputs, this module allows the user to increase or decrease the PWM duty cycle.

* bar_graph: This visual component displays the current duty cycle as a bar graph. It provides a quick and intuitive representation of signal intensity LEDs.

* pwm_generator: This module creates the PWM signals with adjustable duty cycles. It forms the core of the system by generating the output signal that is later visualized and controlled through other components.




### Component(s) simulations

### simulation of debouncer
![simulation of debouncer](imgs/sim_debouncer.png)

### simulation of channel selector
![simulation of channel selector](imgs/sim_channel_selector.png)


### simulation of intensity controller
![simulation of intensity controller](imgs/sim_intensity_controller.png)

### simulation of bar graph
![simulation of bar graph](imgs/sim_bargraph.png)


### simulation of pwm
![simulation of pwm](imgs/sim_pwm.png)

## References

1. https://www.drawio.com/
2. https://github.com/tomas-fryza/vhdl-labs/tree/master
3. https://vhdl.lapinoo.net/
4. https://www.edaplayground.com/
