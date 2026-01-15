# Hacking NIU Electric Scooters (KQI series)

This repository is supposed to serve as a summary of findings when trying to customize the experience of NIU scooters for me in a private manner. I hope it is useful for others. 



## Background Story

I bought a [NIU KQI3 Pro](https://shopeu.niu.com/en-at/products/niu-kqi3-pro-electric-kick-scooter-at-version) scooter at the end of 2024 and it has taken me already almost 3000km since then. Those are very nice scooters and they are really well made. However, there are a few issues that apparently cause issues as soon as something breaks. I'm not going to talk about the pain to fix a flat tire, which is a story on its own. I'm mainly referring to two issues here

- a broken or worn-out battery, and
- the speed limit imposed by the firmware.

Particularely the first one is a big pain. Luckily I did not have a broken battery yet myself, but I was always worried about the range. Sticking to the 25km/h speed limit in Austria, the KQI3 Pro takes me 30km at max. Ok, I'm not a 50kg child, but still - it's far from some 40 or 45km I'd expect. So the question came up, if it is possible to upgrade the range somehow - and this is where all this started. Here is the gist of spending hours on Reddit, Aliexpress and Discord forums:

- There are no replacement batteries for an acceptable price, if available at all
- You cannot replace the battery with any other 48V battery, as the NIU battery BMS communicates over serial to the controller (and the dashboard ultimately).

In practice, this means: if the battery is broken, you have to dump the entire scooter. I'm not going to accept this, so I started investigating a broken [KQI3 Sport](https://shopeu.niu.com/en-at/products/eu-niu-kqi3-sport-electric-kick-scooter-for-adults) scooter I bought cheaply and found that the battery cells were good, but the BMS was broken. 

<img width="1079" height="425" alt="niu-kqi3-battery-bms-v1" src="https://github.com/user-attachments/assets/a8d89af5-c483-47a2-9e07-04a05217a46d" />
<img width="1364" height="586" alt="niu-kqi3-battery-bms-v0" src="https://github.com/user-attachments/assets/e2e3c76c-5d27-4125-b7de-95a6d1bec6a2" />

You guess it: you can't get an original replacement BMS. So I removed the broken BMS and added a replacement one from Aliexpress, but I ran into a new problem: this BMS does not communicate. As a result, the controller goes into Error 42 mode and that's it. And that was the final point where I finally caught fire. 

## Battery Emulator (v1)

So here's the thing. I don't know any scooter that has a *smart* battery, only the NIUs have it. You just can't exchange it with some alternative one like e.g. [this](https://de.aliexpress.com/item/1005008628933535.html) one, as there is no communication and the resulting Error 42. So I got another KQI3 Sport scooter with a working battery and disassembled it completely. The Sport/Pro/Max versions of the KQI3 have 13S3, 13S4 and 13S5 layouts by the way, giving 7.8Ah, 10.4Ah and 13.0Ah capacity respectively. 

**NOTE: If you buy a battery pack somewhere, check the rated capacity and think what it means and if the seller makes a reasonable claim! Given that single cells (and cell blocks) have a maximum capacity of some 2.600mAh to 4.000mAh, you can do the math yourself by adding it up in terms of the serial layout. 13S4 means 4 batteries in parallel and 13 blocks of those, gives 10.4Ah for (4x) 2.600mAh cells and (13x) 4.2V gives 54.6V, which is a 48V battery on full charge.**

So starting with a working setup, I sniffed the communication between the controller and a working battery. With some heavy use of Google Gemini, I analysed the protocol. What I found is that the battery communicates a lot of information about SOC and the individual cell package voltages. The controller queries the battery, gets the information, and does not do anything with this information except for the SOC. Also, you can't really do anything about that information controlling the battery either, because whether the battery pack is balanced or not is the responsibility of the BMS. 

The controller has a set of interfaces with some special JST 2.54mm connectors, which are hard to get overall. Anyway, the serial interface is on the far left of the picture and only 3 wires are connected: GND, RX and TX.

<img width="327" height="244" alt="image" src="https://github.com/user-attachments/assets/3aae4a04-d269-457b-9479-f9366ee88c62" />

I took the fixed battery with the replacement BMS, and created an ESP32-based workaround for the missing serial interface on the BMS. It's a workaround, but it *pretends* to be a battery while not being linked to it at all except for measuring the battery voltage to assess SOC status. Here's the final wiring diagram for an ESP32 S3 Super-Mini board.

<img width="388" height="325" alt="image" src="https://github.com/user-attachments/assets/dcf83b34-0aa2-4328-be24-f3c0dbadd284" />

Just to explain it briefly, the connector to the controller is linked to two GPIOs 4 and 5 as RX/TX. The voltage divider brings the 39.0V-54.6V range down to some 2-3 volts, which can be read by the ESP32 on analog input GPIO 12.

### Tasmota Setup
The ESP32 is flashed with [Tasmota](https://github.com/arendst/Tasmota). and GPIO12 is set to an *Analog Range* input. 

```
AdcParam1 12,2900,3700,0,100
```

### Known issues

- The ESP32 needs some external power supply, which is not shown. For now it is provided by USB, but I will find a solution to power the ESP32.
- The voltage divider is working, but pretty inaccurate I feel. Will look for a separate version.
- Tasmota does not run stand-alone without WIFI. There is a long story around that. In V2, there will be a solution to this as well.

## Disclaimer

⚠️ DANGER OF ELECTROCUTION ⚠️

You very likely loose any guarantee or warranty when modifying your scooter. I don't take any responsibility for any lost warranty or guarantee, any personal harm to anyone, or if anything else going wrong neither during assembly or use. Nor do I take any responsibility if you violate any local regulations concerning driving safety or local guidelines (e.g. max speed in Austria is 25km/h, in Germany it is 20km/h, and so on). Also I have to repeat at this point what is mentioned also in the [Tasmota](https://github.com/arendst/Tasmota) repository in a modified form, particular because working with DC is even more dangerous than working with AC probably:

If your device connects to mains electricity (AC power) there is danger of electrocution if not installed properly - this applies mainly to the part where you connect the charger to the controller/battery/scooter. If you don't know how to install it (or what you are doing overall), either leave it or please call an expert in electronics or talk to a repair shop guy for scooters. Remember: SAFETY FIRST. It is not worth the risk to yourself, your family and your home if you don't know exactly what you are doing. I don't take any responsibility nor liability for for any software part on this page nor for the installation or any tips, advice, videos, etc. given by anyone else in the issues section or elsewhere.

 
