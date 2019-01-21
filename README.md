# Qrop

A crop planning and recordkeeping free software Available on GNU/Linux, Windows and Mac and Android.

**Warning:** this is alpha software with known bugs. It runs, and work at least
some of the times, but use at your own risk.

![Screenshot of Qrop](qrop.png)

## Features

* **Crop planning −** build crop plans including expected yields and harvest
  windows. Easily create, duplicate, delete, batch-edit, sort and filter
  successions.
* **Task management and recordkeeping −** plan your tasks (weeding, seeding,
  planting, stale seed bed, cultivating, etc.) and dynamically keep track of
  them.
* **Field map −** define your field map and assign planting to your beds.

## Planned features

* **Harvests tracking −** keep track of each harvest and get real-time crop yields.
* **Note taking −** write notes, take photos and link them to your plantings, tasks and locations.

## Getting started

### Linux (AppImage)

We only provide AppImages. Download the latest version at
https://github.com/andreh11/qrop/releases. Then open a console in the right folder
and type:

```shell
chmod u+x Qrop-x86_64.AppImage
./Qrop-x86_64.AppImage
```

to launch the AppImage. It has been tested with Ubuntu 16.04 and Fedora 29, but
may not work on other distributions or version.


### Windows

Download the right Zip file for you architecture:

 - https://ah.ouvaton.org/qrop/qrop-0.1.1-x86.zip (32 bit)
 - https://ah.ouvaton.org/qrop/qrop-0.1.1-amd64.zip (64 bit)

Unzip it, open the folder and click on "desktop" to launch the application.

There is no installer yet, but this will be provided as soon as possible.

### OS X

Not tested yet, please contact me if you own a Mac and would like to try Qrop!

## Built With

* C++, QML and Javascript
* Qt5
* SQLite

## Contributing

Please read the [contribution guide](CONTRIBUTING.md) for details of our code of
conduct, and the process for submitting bug reports and merge requests to us.

## Authors

* **André Hoarau** @ah − developer

## License

This project is licensed under the GNU GPLv3 − see [LICENSE](LICENSE) for more details.
