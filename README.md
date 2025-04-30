# Configurable multi-channel Pulse Width Modulation (PWM) for LED brightness control

### Team members

* Vojtěch Smejkal -
* Polák Tomáš -
* Matúš Repáš -

### Abstract

This project presents a configurable multi-channel Pulse Width Modulation (PWM) system designed for precise LED brightness control. The system allows users to adjust the brightness of multiple LEDs independently by varying duty cycles across several PWM channels. A flexible interface enables easy reconfiguration of parameters such as frequency, duty cycle, and channel count, making the design adaptable to various lighting applications. Emphasis is placed on achieving smooth brightness transitions and minimizing flicker through optimized PWM signal generation. The project explores both hardware-based and software-based PWM approaches, balancing performance with resource efficiency. Overall, this configurable PWM solution offers a scalable, customizable method for efficient LED brightness management in diverse environments.

## Hardware description of demo application
The FPGA board uses five buttons: BTNR, BTNL, BTND, BTNU, and BTNC. BTNR and BTNL control the duty cycle of the PWM signal, while BTND and BTNU are used to switch between different PWM outputs. BTNC serves as the central reset button, which restores the PWM settings to default, setting the duty cycle back to 50%.

For input/output, we utilize four pins from the JA Pmod port on the FPGA. Two pins are connected to external LEDs, and the remaining two are used for the BAR segment display. This configuration was necessary because the JB Pmod port, which is our primary interface, did not have enough available pins for the BAR segment display.

![pmod](imgs/Pmod_pinout.png)

### Schematic
![schema](imgs/schema_toplevel.png)
## Software description

Put flowchats/state diagrams of your algorithm(s) and direct links to source/testbench files in `src` and `sim` folders.

### Component(s) simulations

Write descriptive text and put simulation screenshots of components you created during the project.

## References

1. https://www.drawio.com/
2. ...
