# Windows Astrophotography Setup Programm AKA AstroWASP

A simple PowerShell tool to prepare a Windows PC for [N.I.N.A.](https://nighttime-imaging.eu/).

## Detailed Description
Getting a N.I.N.A. PC up and running is relatively easy but fiddly if you don't know what you're doing. This simple PowerShell Script provides a menu to download and install the prequisites, vendor drivers and then N.I.N.A. itself. This was inspired by this tutorial video from Cuiv, The Lazy Geek: https://www.youtube.com/watch?v=ZmY4I-JYueA.

## Usage
1. Download the contents of this repo and extract it.
2. Open Windows PowerShell as administrator.
3. Navigate to the folder you extracted using the `CD` command.
4. Enter `.\AstroWASP.ps1`.
5. Run through the menu from start to finish.

## Detailed Menu Documentation
### 1. Tweaks
Contains registry edits to improve your Windows experience, such as enabling remote desktop and showing hidden files.

### 2. ASCOM Platform
Downloads and installs the latest version of the core ASCOM Platform. This is mandatory for any astro setup.

### 3. ASTAP Core
Downloads and installs the core ASTAP application, required for platesolving. N.I.N.A supports alternatives but IMO this is the best option, so the only one implemented for now.

### 4. ASTAP DB
Downloads and installs the largest version of the ASTAP database, for simplicity. Required for platsolving to work.

### 5. phd2
Downloads and installs phd2 autoguiding. Again N.I.N.A supports alternatives, but this works well out of the box.

### 6. Vendor Drivers
Opens a sub-menu of vendor drivers. This is limited to driver config files bundled with the application, or you can add your own (see below).

### 7. N.I.N.A.
Downloads and installs N.I.N.A. itself.

## Vendor config files

Config files for other vendors can be added to the `Vendors` subfolder using the same csv file structure as the existing files and they will load automatially into the vendor submenu. The structure is as follows:

1. Index: the order in which the driver will appear on the menu.
2. Name: the friendly name of the driver on the menu.
3. Description: a detailed explanation of what selecting this option will do.
4. Uri: the full uri for the download, all the way to the filename.
5. FileName: the name to save the file as.
6. Method: the method with which the programme will download the file. The options are:
   - Standard: downloads the file without any special steps.
   - GitHub: if the file is hosted in a GitHub release.
   - SourceForce: if the file is hosted on SourceForge.
   - Nina: if the file is the N.I.N.A. installer [do not use].

New vendor CSVs could be submitted to this project for inclusion.

## Troubleshooting

- The programme will not start unless it is run as administrator. This is required to save files to disk then execute them.
- Downloaded programmes are saved to the `Installers` subfolder if you need them again.

## Clear skies!
