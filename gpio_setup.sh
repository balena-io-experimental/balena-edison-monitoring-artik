#!/bin/bash

# Mount needed for GPIO pins to be enabled correctly
if mount -l -t debugfs | grep "on /sys/kernel/debug"; then
    echo "debugfs already mounted"
else
    mount -t debugfs nodev /sys/kernel/debug
fi


# From http://www.emutexlabs.com/project/215-intel-edison-gpio-pin-multiplexing-guide
# Example 4: Configure IO18/IO19 for I2C connectivity

echo "Setting up GPIO"

# IO18/SDA Pin Multiplexing
IO18=(14 27 204 236 212)
for i in ${IO18[@]}; do
    if [ ! -e /sys/class/gpio/gpio${i} ]; then
	echo ${i} > /sys/class/gpio/export
    fi
done

# IO19/SCL Pin Multiplexing
IO19=(165 28 205 237 213)
for i in ${IO19[@]}; do
    if [ ! -e /sys/class/gpio/gpio${i} ]; then
	echo ${i} > /sys/class/gpio/export
    fi
done

# TRI_STATE_ALL low before all changes
if [ ! -e /sys/class/gpio/gpio214 ]; then
    echo 214 > /sys/class/gpio/export
fi
echo low > /sys/class/gpio/gpio214/direction 

## Set up parameters
# I2C
echo low > /sys/class/gpio/gpio204/direction 
echo low > /sys/class/gpio/gpio205/direction
# Set as input
echo in > /sys/class/gpio/gpio14/direction 
echo in > /sys/class/gpio/gpio165/direction 
# Disable output
echo low > /sys/class/gpio/gpio236/direction 
echo low > /sys/class/gpio/gpio237/direction 
# Enable pull-up
echo in > /sys/class/gpio/gpio212/direction 
echo in > /sys/class/gpio/gpio213/direction
# I2C-6
echo mode1 > /sys/kernel/debug/gpio_debug/gpio28/current_pinmux 
echo mode1 > /sys/kernel/debug/gpio_debug/gpio27/current_pinmux 

# Re-enabled TRI_STATE_ALL
echo high > /sys/class/gpio/gpio214/direction

# Let it rest
sleep 1
