# UART

## Introduction 


### Clock Divider 
- **Clock Divider** : Generates a clock at the required Baud rate (the rate at which data is transmitted on the communication channel).
- Typical baud rates are 9600,19200,38400,57600,115200 bps, etc
- The clock divider generates a baud clk by dividing the system clock 
- Clk Divider = \frac{System Clock Frequency}{Baud Clock Frequency}
- But this division might not always result in an integer (whole number) we either use the ceil or the floor function. Using the ceil the baud clock would be slightly slower leading to longer bit durations. Floor would round down and the baud clock is slightly faster leading to shorter bit durations. 
- I have use ceil so that the baud clock frequency does not exceed the desired baud rate.

