## Background Story

There are a few issues that apparently cause issues as soon as something breaks. I'm not going to talk about the pain to fix a flat tire, which is a story on its own. I'm mainly referring to two issues here

- a broken or worn-out battery, and
- the speed limit imposed by the firmware.

Particularely the first one is a big pain. Luckily I did not have a broken battery yet myself, but I was always worried about the range. Sticking to the 25km/h speed limit in Austria, the KQI3 Pro takes me 30km at max. Ok, I'm not a 50kg child, but still - it's far from some 40 or 45km I'd expect. So the question came up, if it is possible to upgrade the range somehow - and this is where all this started. Here is the gist of spending hours on Reddit, Aliexpress and Discord forums:

- There are no replacement batteries for an acceptable price, if available at all
- You cannot replace the battery with any other 48V battery, as the NIU battery BMS communicates over serial to the controller (and the dashboard ultimately).

In practice, this means: if the battery is broken, you have to dump the entire scooter. I'm not going to accept this, so I started investigating a broken [KQI3 Sport](https://shopeu.niu.com/en-at/products/eu-niu-kqi3-sport-electric-kick-scooter-for-adults) scooter I bought cheaply and found that the battery cells were good, but the BMS was broken. 

<img width="1079" height="425" alt="niu-kqi3-battery-bms-v1" src="https://github.com/user-attachments/assets/a8d89af5-c483-47a2-9e07-04a05217a46d" />
<img width="1364" height="586" alt="niu-kqi3-battery-bms-v0" src="https://github.com/user-attachments/assets/e2e3c76c-5d27-4125-b7de-95a6d1bec6a2" />

You guess it: you can't get an original replacement BMS. So I removed the broken BMS and added a replacement one from Aliexpress, but I ran into a new problem: this BMS does not communicate. As a result, the controller goes into Error 42 mode and that's it. And that was the final point where I finally caught fire. 