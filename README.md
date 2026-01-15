# Hacking NIU Electric Scooters (KQI series)

This repository is supposed to serve as a summary of findings when trying to customize the experience of NIU scooters for me in a private manner. I hope it is useful for others. 



## Background Story

I bought a [NIU KQI3 Pro](https://shopeu.niu.com/en-at/products/niu-kqi3-pro-electric-kick-scooter-at-version) scooter at the end of 2024 and it has taken me already almost 3000km since then. Those are very nice scooters and they are really well made. However, there are a few issues that apparently cause issues as soon as something breaks. I'm not going to talk about the pain to fix a flat tire, which is a story on its own. I'm mainly referring to two issues here

- a broken or worn-out battery, and
- the speed limit imposed by the firmware.

Particularely the first one is a big pain. Luckily I did not have a broken battery yet myself, but I was always worried about the range. Sticking to the 25km/h speed limit in Austria, the KQI3 Pro takes me 30km at max. Ok, I'm not a 50kg child, but still - it's far from some 40 or 45km I'd expect. So the question came up, if it is possible to upgrade the range somehow - and this is where all this started:

- There are no replacement batteries for an acceptable price, if available at all
- You cannot replace the battery with any other 48V battery, as the NIU battery BMS communicates over serial to the controller (and the dashboard ultimately).

In practice, this means: if the battery is broken, you have to dump the entire scooter. I'm not going to accept this, so I started investigating a broken [KQI3 Sport](https://shopeu.niu.com/en-at/products/eu-niu-kqi3-sport-electric-kick-scooter-for-adults) scooter I bought cheaply and found that the battery cells were good, but the BMS was broken. You guess it: you can't get a replacement BMS. So I removed the broken BMS and added a replacement one from Aliexpress, but I ran into a new problem: this BMS does not communicate. As a result, the controller goes into Error 42 mode and that's it. And that was the final point where I finally caught fire. 

## Battery Emulator

## Disclaimer

⚠️ DANGER OF ELECTROCUTION ⚠️

You very likely loose any guarantee or warranty when modifying your scooter. I don't take any responsibility for any lost warranty or guarantee, any personal harm to anyone, or if anything else going wrong neither during assembly or use. Nor do I take any responsibility if you violate any local regulations concerning driving safety or local guidelines (e.g. max speed in Austria is 25km/h, in Germany it is 20km/h, and so on). Also I have to repeat at this point what is mentioned also in the [Tasmota](https://github.com/arendst/Tasmota) repository in a modified form, particular because working with DC is even more dangerous than working with AC probably:

If your device connects to mains electricity (AC power) there is danger of electrocution if not installed properly - this applies mainly to the part where you connect the charger to the controller/battery/scooter. If you don't know how to install it (or what you are doing overall), either leave it or please call an expert in electronics or talk to a repair shop guy for scooters. Remember: SAFETY FIRST. It is not worth the risk to yourself, your family and your home if you don't know exactly what you are doing. I don't take any responsibility nor liability for for any software part on this page nor for the installation or any tips, advice, videos, etc. given by anyone else in the issues section or elsewhere.

 
