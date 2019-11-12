# VESC_Dashboard
iOS application for VESC controller

Setup VESC controller baud to work with Bluetooth baud.
Run application and find TX and RX characters.

http://www.hangar42.nl/hm10 <br />
BAUD HM-10    115200   //Flashed here<br /> http://www.hangar42.nl/ccloader<br />
The HM10 has one service, 0xFFE0, which has one characteristic, 0xFFE1 (these UUIDs can be changed with AT commands by the way)
<br />
