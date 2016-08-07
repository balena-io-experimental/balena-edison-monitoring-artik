"""
Temperature monitoring with Intel Edison and Samsung ARTIK Cloud
"""
import os
import time

import artikcloud
import pyupm_grove as grove
import mraa

# Setting credentials from the environmental variables
DEVICE_ID = os.getenv('ARTIKCLOUD_DEVICE_ID')
DEVICE_TOKEN = os.getenv('ARTIKCLOUD_DEVICE_TOKEN')

# Setting up ARTIK Cloud connection
api_client = artikcloud.ApiClient()
api_client.set_default_header(header_name="Authorization", header_value="Bearer {}".format(DEVICE_TOKEN))

# Setting up messaging
messages_api = artikcloud.MessagesApi(api_client)

# Create the temperature sensor object using AIO pin 0
temp = grove.GroveTemp(0)
print(temp.name())
led = mraa.Gpio(4)
led.dir(mraa.DIR_OUT)

i = 0
while True:
    celsius = temp.value()
    print("Current temperature: {}".format(celsius))
    if i % 600 == 0:
        # Send a new message
        message = artikcloud.MessageAction()
        message.type = "message"
        message.sdid = "{}".format(DEVICE_ID)
        message.ts = int(round(time.time() * 1000))  # timestamp, required
        message.data = {'Temperature': celsius}
        response = messages_api.send_message_action(message)
        print(response)
        i = 0
        led.write(1)
        time.sleep(0.1)
        led.write(0)
    i += 1
    time.sleep(1)
