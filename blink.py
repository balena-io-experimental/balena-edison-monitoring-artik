import time
import sys

import mraa

###### Setting up at start

led = mraa.Gpio(4)
led.dir(mraa.DIR_OUT)

def ledblink():
    while True:
        led.write(1)
        time.sleep(0.5)
        led.write(0)
        time.sleep(0.5)

if __name__ == "__main__":
    ledblink()
