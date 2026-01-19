# Hacking NIU Electric Scooters (KQI series)

This repository is supposed to serve as a summary of findings when trying to customize the experience of NIU scooters for me in a private manner. I hope it is useful for others. 

## Background Story

I bought a [NIU KQI3 Pro](https://shopeu.niu.com/en-at/products/niu-kqi3-pro-electric-kick-scooter-at-version) scooter at the end of 2024 and it has taken me already almost 3000km since then. Those are very nice scooters and they are really well made. Read [more](./bg.md)...

## Battery Emulator (v1)

Read more about v1 [here](./v1.md).

## Improved Battery Emulator (v2)

The biggest issue is the supply voltage to the ESP and the fact that it will be "on" all the time. This will be part of the next iteration of work, and is current (Jan 15, 2026) work in progress, planned to be finished and documented in the coming weeks.

## Disclaimer

⚠️ DANGER OF ELECTROCUTION ⚠️

You very likely loose any guarantee or warranty when modifying your scooter. I don't take any responsibility for any lost warranty or guarantee, any personal harm to anyone, or if anything else going wrong neither during assembly or use. Nor do I take any responsibility if you violate any local regulations concerning driving safety or local guidelines (e.g. max speed in Austria is 25km/h, in Germany it is 20km/h, and so on). Also I have to repeat at this point what is mentioned also in the [Tasmota](https://github.com/arendst/Tasmota) repository in a modified form, particular because working with DC is even more dangerous than working with AC probably:

If your device connects to mains electricity (AC power) there is danger of electrocution if not installed properly - this applies mainly to the part where you connect the charger to the controller/battery/scooter. If you don't know how to install it (or what you are doing overall), either leave it or please call an expert in electronics or talk to a repair shop guy for scooters. Remember: SAFETY FIRST. It is not worth the risk to yourself, your family and your home if you don't know exactly what you are doing. I don't take any responsibility nor liability for for any software part on this page nor for the installation or any tips, advice, videos, etc. given by anyone else in the issues section or elsewhere.

 
