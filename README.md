# Hacking NIU Electric Scooters (KQI series) - ESP32-driven BMS emulator

This repository is supposed to serve as a summary of findings when trying to customize the experience of NIU scooters for me in a private manner. I created an ESP32-driven workaround for broken batteries. I hope it is useful for others. 

## Background Story

I bought a [NIU KQI3 Pro](https://shopeu.niu.com/en-at/products/niu-kqi3-pro-electric-kick-scooter-at-version) scooter at the end of 2024 and it has taken me already almost 4500km since then. Those are very nice scooters and they are really well made. Read [more](./bg.md)...

## Battery Emulator (v1)

Read more about v1 [here](./v1.md).

## Improved Battery Emulator (v2)

Like in v1, I created an ESP32-based workaround for the missing serial interface on the BMS. It's a workaround, and it *pretends* to be a battery while not being linked to it at all except for measuring the battery voltage to assess SOC status. I chose an ESP32 Relay board, because it allows for connecting up to 60V power supply with an integrated power circuit to bring this down to 5V the ESP32 needs. Again, it also has [Berry](https://tasmota.github.io/docs/Berry/) support.

![IMG_0795](https://github.com/user-attachments/assets/ea49b247-e395-4155-8b57-aa7ddc050935)

In this case the connector to the controller is linked to two GPIOs 14 and 13 as RX/TX. The (very simple) voltage divider brings the 39.0V-54.6V range from the battery down to some 2-3 volts, which can be read by the ESP32 on analog input GPIO 34. The capacitor is used for smoothing and can be omitted if not available. Now, in order to get the battery voltage, you can use a Y-cable. 

*Note: You can change the GPIOs to what you like, but note that e.g. GPIO 12 is internally linked to the flash voltage. Because the ESP32 needs to have this one floating on boot and the controller will pull it down, the ESP32 does not boot if it is connected to GPIO 12. The same likely applies to GPIO 0 or 2.*

**TAKE CARE TO NOT FRY THE BOARD OR YOURSELF.**

### Tasmota Setup
The ESP32 is flashed with [Tasmota](https://github.com/arendst/Tasmota). Get information how to do that from there. There are two important things to consider here:

- Tasmota is not supposed to run in standalone mode. In other words, it will reset after 3 minutes if not connected to a network. This is bad, but luckily there is a [patch](https://github.com/arendst/Tasmota/discussions/13362) for that.
- The ESP32 will be always on, which is bad, unnecessary and drains battery over time. Luckily there is a feature called ULP (Ultra-Low-Power) which we can use.

So we patch the sources and include ULP support. ULP is the mode allowing the ESP32 to turn completely off and to come back to life based on e.g. an interrupt or counting edges on GPIOs. The precompiled binaries in the [prebuilts](https://github.com/belveder79/NIUScooterHacking/tree/main/prebuilts) folder include ULP support and the patch.

After flashing, if you connect the ESP32 to power, it will spawn a WIFI hotspot and will be available under a weird name like `tasmota_XXXXXX`. The IP is `192.168.4.1`. 

- You can change the hostname. The WIFI hotspot will from then on have the same name.
- Set GPIO 34 to an *Analog Range* input.
- On the *Console* you need to map the parameters for the input to a plausible SOC value. I have not really calibrated it yet, but these values seem to work to scale the SOC to give something between 0 and 100%
  ```
    AdcParam1 12,2900,3700,0,100
  ```
  
Then you can move on with uploading the scripts.

### Berry Scripts

Finally, you need to put the [autoexec.be](https://github.com/belveder79/NIUScooterHacking/blob/main/v2/autoexec.be) and the [runulp.be](https://github.com/belveder79/NIUScooterHacking/blob/main/v2/runulp.be) Berry scripts into the file system of the ESP32 and restart. Done!

The biggest issue previously was to get the supply voltage to the ESP. The Relay board solves that elegantly now. And here's the catch: 

***We can now use the ULP mode listening on the TX line of the ESP32 to power it up and down once the scooter is powered on/off***. 

In a nutshell, over the RX/TX line the controller requests data from the battery, respectively the emulator. But it stops requesting data once it is powered of and the TX/RX lines stay silent. If there is no communication, the ESP32 recognizes this and goes into ultra deep sleep mode, as there's a timer in the script which checks if there has been any communication with the controller. On timer expiration, it calls the sleep script. The Berry script currently waits for ***30 seconds*** before sending the ESP to sleep. In ULP mode, it listens on GPIO 14 and if there is an edge detected, it turns on automatically.

### Updating Scooter Firmware

Below there are a few links to upgrade the firmware of the scooter with a modified Android app. During any update, the controller does not send the usual packages. Therefore, the ESP will go to sleep, which leads to upgrade failure. 

If you are trying to update the firmware of the scooter, make sure that you ***disable the `runULP.be` *** before doing so. It is fine to add a `return` statement as the first line in the script, which can be easily removed after the upgrade has succeeded.

### Parts list

- XT60 Y-cable [Amazon](https://www.amazon.de/VUNIVERSUM-Goldstecker-Adapterkabel-Mr-Stecker-Modellbau%C2%AE/dp/B078NZ7VQQ)
- ESP32 Relay board [Amazon](https://www.amazon.de/dp/B0CYSMFB49)
- JST connectors + cables
- Case [Amazon](https://www.amazon.de/dp/B0BZBW4Z9K)

## More links to modify the NIU scooters

Here are a few links for modifying the NIU scooters:

- Update App video on [Youtube](https://www.youtube.com/watch?v=AeFOrXQ4Fkc)
- [NIU Firmwares](https://github.com/scooterhacking/niu_scooters)
- Explainer video on [Youtube](https://www.youtube.com/watch?v=alblypvLAAQ)

## Disclaimer

⚠️ DANGER OF ELECTROCUTION ⚠️

You very likely loose any guarantee or warranty when modifying your scooter. I don't take any responsibility for any lost warranty or guarantee, any personal harm to anyone, or if anything else going wrong neither during assembly or use. Nor do I take any responsibility if you violate any local regulations concerning driving safety or local guidelines (e.g. max speed in Austria is 25km/h, in Germany it is 20km/h, and so on). Also I have to repeat at this point what is mentioned also in the [Tasmota](https://github.com/arendst/Tasmota) repository in a modified form, particular because working with DC is even more dangerous than working with AC probably:

If your device connects to mains electricity (AC power) there is danger of electrocution if not installed properly - this applies mainly to the part where you connect the charger to the controller/battery/scooter. If you don't know how to install it (or what you are doing overall), either leave it or please call an expert in electronics or talk to a repair shop guy for scooters. Remember: SAFETY FIRST. It is not worth the risk to yourself, your family and your home if you don't know exactly what you are doing. I don't take any responsibility nor liability for for any software part on this page nor for the installation or any tips, advice, videos, etc. given by anyone else in the issues section or elsewhere.

 
