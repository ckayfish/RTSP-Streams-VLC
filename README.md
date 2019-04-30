# RTPS-Streams-VLC
PowerShell script to manage multiple RTSP streams with VLC. Originally written for use with my personal WYZE cameras when RTSP was released in 2019

We use VLC to get many RTSP streams from local cameras, and then send them to various outputs including:

- Display the live streams in VLC
- Write the video stream to a file
- Create an HTTP output for each stream, so in can be embedded in webpages

This is used mostly to experiment, and play with making a custom solution. There are many more professional alternatives to process your RTSP streams and no one is suggesting this is preferable in any way. I simply enjoy creating little projects like this. I keep projects open in case anyone else may find it useful during their own journey.

I use it primarily to save my streams to a file, which are archived for access anytime later. If the data on the SD card is inaccessible, I have these. I also created a website which displays the feed on the internet using the converted HTTP streams.

### Prerequisites

1. This is written in PowerShell, which is a MS Windows scripting language. If you aren't using Windows, this solution is probably not for you, but other platforms may support it. This was created and tested with PowerShell 5.1 on Windows 10.

2. In order to execute foreign scripts, you may need to modify your execution policy. You can do this by opening PowerShell **as an administrator** and run the following command. You can find more details here: <https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-6>

   ```
   set-executionpolicy unrestricted
   ```

3. We use VLC, from VideoLAN, to get and process the RTSP streams. If you don't yet have it, you can get it here: https://www.videolan.org/vlc/

4. If you are using Wyze cameras like I am, they provide instructions for setting up RTSP, which includes manually installing firmware. This must be done, and you must have your generated RTSP URL if you want to use this script with WYZE cameras https://support.wyzecam.com/hc/en-us/articles/360026245231-Wyze-Cam-RTSP

### Installing/Running

Simply  place the ps1 file in somewhere on you computer, edit the file to set the variables as described in the comments, then execute the script. The easiest way to do this is by opening the .ps1 file in PowerShell ISE

- Ensure pre-requisites are met
- Download this project into a folder of your choice, ensuring you have th ps1 file
- Start PowerShell ISE, and open the ps1 file
- Edit the variables at the top for your environment. It's strongly suggested you start first by only changing 2 variables, and then playing with the rest later:
  - Setting the full path to your vlc.exe
  - Adding your cameras, replacing the defaults, into the variable $cameraStreams
- Clicking the green arrow in the menu to save & run the script



## Some Notes

These are things to keep in mind, including common questions

- Using DHCP reserved IP addresses for your cameras will simplify your life by ensuring the URL for your camera doesn't change when you restart it. Your WiFi router should have an app or URL you can use to manage its configuration and set certain devices like your camera to have a "reserved" address that it will be given every time

- I'm looking for the most compatible codecs to use. In order to stream via HTTP, we are using the OGG container with the 'theo' video codec and the 'vorb' audio codec. This also decreases the saved file size by about 1/4. The optional mp4 transcode uses the original video stream, which is AVC for Wyze,  and the mpga audio codec

  



## Authors

* **Curtis Kayfish** - *Initial work* - [ckayfish](https://github.com/ckayfish)

## License

This project is licensed under the MIT License - see the [webpage](https://choosealicense.com/licenses/mit/) for details

Put simply, you can use/copy/edit/publish however you like at your own risk.

## Acknowledgments

* Thank you to [Wyze](https://www.wyze.com/) for their great products, at an affordable price, and for including RTPS as an optional feature
* This would not have been possible without [VideoLan](https://www.videolan.org/) and VLC: the best, most powerful free and open source multimedia player there ever was.
* Some inspiration was provided from the community members of the [WYZE Core Community](https://www.facebook.com/groups/298350110642283/) group on Facebook.
