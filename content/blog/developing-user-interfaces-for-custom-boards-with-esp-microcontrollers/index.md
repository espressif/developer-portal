---
title: Developing User Interfaces for Custom Boards with ESP microcontrollers
date: 2022-10-10
showAuthor: false
authors: 
  - vilem-zavodny
---
[Vilem Zavodny](https://medium.com/@vilem.zavodny?source=post_page-----b8bc2ad04a00--------------------------------)

[Follow](https://medium.com/m/signin?actionUrl=https%3A%2F%2Fmedium.com%2F_%2Fsubscribe%2Fuser%2Fa48886fe8de1&operation=register&redirect=https%3A%2F%2Fblog.espressif.com%2Fdeveloping-user-interfaces-for-custom-boards-with-esp-microcontrollers-b8bc2ad04a00&user=Vilem+Zavodny&userId=a48886fe8de1&source=post_page-a48886fe8de1----b8bc2ad04a00---------------------post_header-----------)

--

A few weeks ago in [this article](/making-the-fancy-user-interface-on-esp-has-never-been-easier-e44e79c0ae3) we have introduced SquareLine Studio and how it can be used to develop user interfaces. This feature was available only for Espressif’s boards. But what if we wanted to use this tool for our custom designed board based on an ESP chip with a custom LCD? Here is the solution!

What is the best way to add a custom board into SquareLine Studio? Start with the [*custom_waveshare_7inch* example on from esp-bsp repository on GitHub](https://github.com/espressif/esp-bsp/tree/master/SquareLine/boards/custom_waveshare_7inch). This example is based on the same code as other Espressif’s examples for SquareLine Studio. However there is one big difference. There must be a custom component similar to Espressif’s BSP with main functions for handling the LCD screen and initialization of the LVGL graphic library.

For this example we have selected the following LCD display: [WaveShare 7inch 800x480 with RA8875 graphical controller and GT911 touch screen controller](https://www.waveshare.com/7inch-capacitive-touch-lcd-c.htm).

## 1. Making the custom BSP for your board

First step in preparing the package for the SquareLine Studio is to make a component similar to BSP. You can see implementation for the [7inch WaveShare LCD](https://www.waveshare.com/7inch-capacitive-touch-lcd-c.htm) in our example on [GitHub](https://github.com/espressif/esp-bsp/tree/master/SquareLine/boards/custom_waveshare_7inch), where only important functions are implemented in [__ws_7inch.c__ ](https://github.com/espressif/esp-bsp/blob/master/SquareLine/boards/custom_waveshare_7inch/components/ws_7inch/ws_7inch.c) file. For other screens, the following functions should be changed:

```
/* LCD display initialization */
static lv_disp_t *lvgl_port_display_init(void)
{
    ...
}/* Touch initialization */
static esp_err_t lvgl_port_indev_init(void)
{
    ...
}
```

If the communication with thetouch screen isn’t over I2C, there must be initialization of the SPI or some other communication interface instead of this:

```
esp_err_t bsp_i2c_init(void)
{
    ...
}
```

Second part of making a custom BSP is to edit the header file [__ws_7inch.h__ ](https://github.com/espressif/esp-bsp/blob/master/SquareLine/boards/custom_waveshare_7inch/components/ws_7inch/include/bsp/ws_7inch.h). This is where are all pin configurations, communication speed configuration and screen size for the board are defined.

The last thing you should do is to modify [__CMakeLists.txt__ ](https://github.com/espressif/esp-bsp/blob/master/SquareLine/boards/custom_waveshare_7inch/components/ws_7inch/CMakeLists.txt) and [__idf_component.yml__ ](https://github.com/espressif/esp-bsp/blob/master/SquareLine/boards/custom_waveshare_7inch/components/ws_7inch/idf_component.yml), when any filename changes or when you need to use another component for the LCD screen or touch screen. You should modify [__idf_component.yml__ ](https://github.com/espressif/esp-bsp/blob/master/SquareLine/boards/custom_waveshare_7inch/main/idf_component.yml) in the main project too when the component name is changed.

## 2. The board description file and board image

After the custom BSP is done, we can move to update the board description file____ [__manifest.json__ ](https://github.com/espressif/esp-bsp/blob/master/SquareLine/boards/custom_waveshare_7inch/manifest.json):

```
{
    "name":"Custom WaveShare 7inch",
    "version":"1.0.0",
    "mcu":"ESP32",    "screen_width":"800",
    "screen_height":"480",
    "screen_color_swap":true,    "short_description":"WaveShare 7inch Display",
    "long_description":"Example of the custom BSP and custom LCD",    "placeholders":
    {
        "__ESP_BOARD_INCLUDE__": "bsp/ws_7inch.h",
        "__ESP_BOARD_I2C_INIT__": "/* Initialize I2C (for touch) */\n    bsp_i2c_init();"
    }
}
```

Values __name__ , __version, mcu, short_description__ and __long_description__ are only for displaying your board right in the SquareLine Studio. There can be anything. More important are values __screen_width__ , __screen_height__  and __screen_color_swap__ , which define physical values for your LCD display. The __placeholders__ should be updated with the right values from your custom BSP. The header file path into ____ESP_BOARD_INCLUDE____  and touch screen initialization function into ____ESP_BOARD_I2C_INIT____ .

Second file for update is board image____ [__image.png__ ](https://github.com/espressif/esp-bsp/blob/master/SquareLine/boards/custom_waveshare_7inch/image.png). There must be a board image in size __380px__  x __300px__ .

## 3. ESP-IDF and LVGL default configuration

If you have any specific changes in IDF configuration or LVGL configuration, you can put it into [__sdkconfig.defaults__ ](https://github.com/espressif/esp-bsp/blob/master/SquareLine/boards/custom_waveshare_7inch/sdkconfig.defaults) file. The configuration option __CONFIG_LV_COLOR_16_SWAP__  must be same like value in __screen_color_swap__ in [__manifest.json__ ](https://github.com/espressif/esp-bsp/blob/master/SquareLine/boards/custom_waveshare_7inch/manifest.json) file.

## 4. Generate and copy package for SquareLine Studio

After all changes are done in files, create the package by run generator in [root SquareLine generator folder](https://github.com/espressif/esp-bsp/tree/master/SquareLine):

```
python gen.py -b custom_waveshare_7inch -o output_folder
```

The package will be generated into __espressif__ folder in __output_folder__ . The last step is to copy this generated package __espressif/custom_waveshare_7inch__  into the __boards__ folder in the SquareLine Studio installation folder.

## 5. Launch the SquareLine Studio

After launching the SquareLine Studio, you should see your board in the Create tab and Espressif tab. There should be your board name, description and image.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*8pMZdE4980CeZWY3S_njXw.png)

## Conclusion

Now, you can create your own project with the custom board. You can use a lot of widgets from LVGL. I can give the recommendation to you, don’t use zoom in image, if it is not necessary, resize image in another image editor and use in full size. The zoom function can be slower and the bigger image can take a lot of the size of the microcontroller flash memory.

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*5URISIooM2P_NFZ0TvqikA.png)

When your project is done, then export the template by selecting __Export->Create Template Project__  in the main menu and export UI files by __Export->Export UI Files__  in the main menu.

The last step is build and flash by command like this:

```
idf.py -p COM34 flash monitor
```

![](https://miro.medium.com/v2/resize:fit:640/format:webp/1*zk3iD7HXiRn-sO7pop73KA.jpeg)

The second recommendation is, don’t forget to change the size of the factory partition in the partitions.csv file and change the flash size of your selected module in menuconfig, when you are using bigger images. Or you will see that the built application is too big and there is no space for downloading it.
