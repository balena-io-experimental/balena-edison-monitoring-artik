"""
Temperature monitoring with Intel Edison and Samsung ARTIK Cloud
"""
import os
import time
from math import log
import statistics

import artikcloud
from artikcloud.rest import ApiException
import pyupm_grove as grove
import mraa

# Setting credentials from the environmental variables
DEVICE_ID = os.getenv('ARTIKCLOUD_DEVICE_ID')
DEVICE_TOKEN = os.getenv('ARTIKCLOUD_DEVICE_TOKEN')
AVERAGE = os.getenv('AVERAGE', 5)

# Setting up ARTIK Cloud connection
artikcloud.configuration.access_token = DEVICE_TOKEN

# Setting up messaging
messages_api = artikcloud.MessagesApi()

# Create the temperature sensor object using AIO pin 0
temp = grove.GroveTemp(0)
print(temp.name())
led = mraa.Gpio(4)
led.dir(mraa.DIR_OUT)

def temp_convert(sensor):
    """Adapted from UPM source code
    https://github.com/intel-iot-devkit/upm/blob/4faa71d239f3549556a61df1a9c6f81c3d06bda2/src/grove/grovetemp.cxx#L54-L63
    """
    a = sensor.raw_value()
    if a < 0:
        return -300
    m_scale, m_r0, m_b = 1.0, 100000.0, 4275.0
    # Apply scale factor after error check
    a *= m_scale
    r = (1023.0-a)*m_r0/a
    t = 1.0/(log(r/m_r0)/m_b + 1.0/298.15)-273.15
    return t

i = 0
readings = []
while True:
    celsius = temp_convert(temp)
    readings.append(celsius)
    if len(readings) > AVERAGE:
        readings.pop(0)
    meancelsius = statistics.mean(readings)
    print("Current temperature: {0:.2f} (mean: {1:.2f})".format(celsius, meancelsius))
    if i % 600 == 0:
        # Send a new message
        message = artikcloud.Message()
        message.type = "message"
        message.sdid = "{}".format(DEVICE_ID)
        message.ts = int(round(time.time() * 1000))  # timestamp, required
        message.data = {'Temperature': meancelsius}
        try:
            response = messages_api.send_message(message)
        except ApiException:
            raise
        print(response)
        i = 0
        led.write(1)
        time.sleep(0.1)
        led.write(0)
    i += 1
    time.sleep(1)
