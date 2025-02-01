## **XI Installer by Scott Lassen & John McClelland**  
## **2025 Modification with Updated Instructions, Registry Entries, and Ashita 4 by Joshua Hughes**

---

### FFXI Install Prerequisites

1. **Install FFXI Retail:**  
   Follow the [LandSandBoat Client Setup for Windows](https://github.com/LandSandBoat/server/wiki/Client-Setup-Windows) instructions to install and update the retail version of FFXI.
2. **Download Ashita v4:**  
   Get Ashita v4 from the [Ashita Installation Guide](https://docs.ashitaxi.com/installation/install_zip/).
3. **Configure Ashita:**  
   Create a configuration file with your server’s information. For details, refer to the [Ashita Configuration Documentation](https://docs.ashitaxi.com/usage/configurations/).
4. **Obtain XILoader:**  
   Download the latest XILoader file (or build your own) from the [XILoader Releases](https://github.com/LandSandBoat/xiloader/releases).
5. **Integrate XILoader:**  
   Place the XILoader file into the `\Ashita\Bootloader` directory. Make sure your config file points to XILoader instead of the default `pol.exe`.
6. **Prepare Data Archive:**  
   Create a folder called `Data` and copy the contents of the following directories into it:  
   - Your Ashita folder  
   - The retail FFXI folder (typically located at `C:\Program Files (x86)\PlayOnline\SquareEnix\FINAL FANTASY XI`)  
   - The retail PlayOnlineViewer folder (typically located at `C:\Program Files (x86)\PlayOnline\SquareEnix\PlayOnlineViewer`)
7. **Create data.pak Archive:**  
   Once all folders are consolidated in one location, select them, right-click, and choose **7zip > Add to Archive**.
8. **Configure 7zip Options:**  
   Use the 7zip options as shown below:  
   
   ![7zip Options](https://github.com/user-attachments/assets/0301deb2-6a52-4359-95a0-3ab54fb4a155)
   
9. **Finalize Archive:**  
   You now have your `data.pak` file. If modifications are needed, rename it to `data.7z`, extract the files, make your changes, and rezip.

---

### Development Setup

1. **Download Visual Studio Redistributables:**  
   Download and include the full (non-web) runtime installers for Visual Studio 2010, 2012, 2013, 2015, and 2017. Rename each installer accordingly (e.g., `VS2010.exe` for the Visual C++ Redistributable for Visual Studio 2010 x86). The download links are provided in the next section.
2. **Download .NET Framework 4:**  
   Download Microsoft .NET Framework 4 and rename the file to `dotNetFx40_Full_x86_x64.exe`.
3. **Download .NET Framework 4.5:**  
   Download Microsoft .NET Framework 4.5 and rename the file to `dotNet45.exe`.
4. **Install NSIS:**  
   Download and install [NSIS](https://nsis.sourceforge.io/Download).
5. **Install NSIS 7z Plugin:**  
   Download the [NSIS 7z Plugin](https://nsis.sourceforge.io/Nsis7z_plug-in#Download).  
   Place the downloaded `nsis7z.dll` file into the appropriate NSIS plugin directories:  
   - For ANSI: `/Program Files (x86)/NSIS/Plugins/x86-ansi`  
   - For Unicode: `/Program Files (x86)/NSIS/Plugins/x86-unicode`

---

### Development Dependency Resource Links

| **Resource** | **Download** |
| :----------- | :----------- |
| Visual C++ Redistributable for Visual Studio 2010 x86 | [Download](https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x86.exe) |
| Visual C++ Redistributable for Visual Studio 2012 x86 | [Download](https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x86.exe) |
| Visual C++ Redistributable for Visual Studio 2013 x86 | [Download](http://download.microsoft.com/download/0/5/6/056DCDA9-D667-4E27-8001-8A0C6971D6B1/vcredist_x86.exe) |
| Visual C++ Redistributable for Visual Studio 2015 x86 | [Download](https://download.microsoft.com/download/9/3/F/93FCF1E7-E6A4-478B-96E7-D4B285925B00/vc_redist.x86.exe) |
| Visual C++ Redistributable for Visual Studio 2017 x86 | [Download](https://download.microsoft.com/download/1/F/E/1FEBBDB2-ADED-4E14-9063-39FB17E88444/vc_redist.x86.exe) |
| Microsoft .NET Framework 4 | [Download](https://download.microsoft.com/download/9/5/A/95A9616B-7A37-4AF6-BC36-D6EA96C8DAAE/dotNetFx40_Full_x86_x64.exe) |
| Microsoft .NET Framework 4.5.2 | [Download](https://download.microsoft.com/download/E/2/1/E21644B5-2DF2-47C2-91BD-63C560427900/NDP452-KB2901907-x86-x64-AllOS-ENU.exe) |

---

### Development

- **Registry Entries:**  
  **Important:** Update registry entries if you experience issues launching the game in Ashita. Outdated or incorrect registry entries are a common cause of problems. Registry values can be found and updated in `Script.nsi` (look for the section marked `;Register with Windows`).

- **Adding a Background Image:**  
  Add a background image in BMP format named `background.bmp` and place it in the project’s root folder (the same folder as `Script.nsi`).

- **Adding an Icon:**  
  Add an installer icon in ICO format named `installer.ico` and place it in the project’s root folder.

- **Adding a License File:**  
  Include a text file (`license.txt`) with your license, disclaimers, or any other information that users must accept before proceeding with the installation. Place this file in the project’s root folder.

- **Bundling Data:**  
  Include the data archive (`data.pak`) in the project’s root folder. This archive should contain all files that will be installed on the user’s system (game data, bootloaders, etc.). Use a tool like 7zip to compress the necessary folders into `data.pak`.

- **Compiling the Installer:**  
  Right-click on `Script.nsi`, select **Compile NSIS Script**, and then click **Test Installer** to ensure everything works correctly.

- **Folder Structure Example:**  
  Your project folder should resemble the following:  
  
  ![Project Folder Structure](https://github.com/user-attachments/assets/f3118abf-6a28-4d71-ad14-c7cd75118b9f)

---

### How to Install

1. **Prepare Files:**  
   Ensure you have both the `installer.exe` and `data.pak` files in the same folder.
2. **Run the Installer:**  
   Double-click `installer.exe` and follow the on-screen instructions. Do not skip or cancel the automatic installation of dependencies.
3. **Reboot:**  
   Once the installation is complete, reboot your PC. You should then be ready to launch the game!

---

### Disclaimer

We are not affiliated, associated, authorized, or endorsed by Square Enix, Final Fantasy, FFXI, or any of its subsidiaries. All FFXI content and images are the property of SQUARE ENIX CO., LTD. FINAL FANTASY is a registered trademark of Square Enix Co., Ltd.

---

### License

Copyright (c) 2018-2020 Eden Server

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software 
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.
2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.

