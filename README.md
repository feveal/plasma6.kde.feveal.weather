# kde.feveal.weather (2.0) for Plasma 6

This Plasmoid provides weather forecast on the image of an old barometer. The needle shows the temperature. The image also appears with the current prediction, temperature and other details. It also has an animated anemometer that rotates depending on the wind speed. By clicking on the image of current weather, the information for subsequent days appears and disappears. Likewise, the anemometer can be stopped by clicking on it. Shows the image of the moon with lighting data and others. By clicking with the mouse on different points in the image, these details are shown or hidden.
You can change the temperature units between Celsius, Fahrenheit and Kelvin. Also change the font size and color.

**NOTE:** Please note that all servers do not provide certain data, for example "wetter.com" does not provide current temperature or wind speed, therefore you will not see the current temperature data, the needle will not be visible, and the anemometer will not spin. If they are available for your location, use other servers such as BBC or NOAA.

## Screenshots
![](https://github.com/feveal/plasma6.kde.feveal.weather/-/raw/main/Screenshot_baro.png)
-
![](https://github.com/feveal/plasma6.kde.feveal.weather/-/raw/main/plasma_baro.mp4)
-

## Getting started:
Unzip the file. Look in the unzipped folder the file "install_plasmoid.sh". Open the terminal in the folder where the file is located.

Run in terminal "./install_plasmoid.sh"
The Plasmoid is installed just like the rest. ".local/share/plasma/plasmoids/kde.feveal.weather/"

Sometimes when resizing the plasmoid, the characters with the moon data do not appear correctly. Use the "restartplasma" file from the terminal by running "./restartplasma"

> **[!Attention:]**
> Check that the **"moon.zip"** file has been correctly unzipped to the destination path. They are images of phases of the moon. They have been put in a zip because the "opencode,net" server does not support files named with blank spaces.

The Plasmoid is integrated  with the rest.

## Description:
Plasmoid for KDE Desktop

(Version 2) New Version for Plasma 6

## Authors and acknowledgment:
Fernando Velez (feveal@hotmail.com). Special thanks to Zren (zrenfire@gmail.com), I have used part of your Condensed Weather code.

## License:
For open source projects, say how it is licensed
