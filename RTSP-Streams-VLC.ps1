####################################################################################################
##************************************************************************************************##
#                                                                                                  #
# Project located at: https://github.com/ckayfish/RTSP-Streams-VLC                                 #
#                                                                                                  #
# This script uses VLC to get many RTSP streams and send them to various outputs inclduing:        #
#   1) Display live with VLC (Default)                                                             #
#   2) Save stream to file                                                                         #
#   3) Re-stream with HTTP for use on websites                                                     #
#                                                                                                  #
# Written by Curtis Kayfish for use with his personal WYZE cameras when RTSP was released - 2019   #
#                                                                                                  #
# NOTE: To run this script you may have to allow it with 'set-executionpolicy'. This up up to you. #
#       https://superuser.com/questions/106360/how-to-enable-execution-of-powershell-scripts       #
#                                                                                                  #
# This depends on VLC, a free and OpenSource multimedia player - https://www.videolan.org/         #
#                                                                                                  #
# You can select which 1, many or all outputs to send your streams to. You will need to configure  #
# the following variables in order to use some or all features                                     #
#                                                                                                  #
#    * $pathToVlcExe - the full path to where vlc.exe is located on your file system               #
#    * $cameraStreams - a list of all the RTSP streams you want to get. Name is arbitrary          #
#    * $pathToSaveFiles - drive & folder you want to save your network streams to. All streams     #
#                         will be saved to the same folder with the camera name and time stamp     #
#                         Please be sure have lots of space to store the streams!                  #
#    * $transcode - Select either OGG or MP4. OGG is default and will be forced if streaming       #
#                   output includes HTTP. With MP4 the original video stream is kept. WYZE cameras #
#                   are sending the video as AVC                                                   #
#    * $playInVlc / $saveToFile / $convertToHttp - Set each feature you want to use to 1           #
#                                                  If none selected, streams will play in VLC      #
#    * $buffer - Network buffer in milliseconds, default of 1000 (1 second). The shorter the       #
#                buffer, the less delay, and less time for VLC to stitch the stream together       #
#    * $port - Starting port to serve HTTP steams.  Default is 8080 and they increment by 1.       #
#              With 4 cameras, their HTTP ports in order will be 8080, 8081, 8082 etc.             #
#                                                                                                  #
# Other notes                                                                                      #
#   - If $convertToHttp is selected, OGG transcoding is forced. Mp4 can't be streamed through VLC  #
#   - It's highly recommended to use DHCP reserved IP addresses on your router for your cameras    #
#   - Ideal use case-now is to display in VLC and save to file. HTTP is unstable.                  #
#                                                                                                  #
##************************************************************************************************##
####################################################################################################

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#!!!!!!!!!!!!!! PLEASE SET THE VARIABLES BELOW HERE AND IGNORE EVERYTHING AFTER WARNING !!!!!!!!!!!#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#

# Set the path to vlc.exe on your system.
# *Required. Default is C:\Program Files\VideoLAN\VLC\vlc.exe
$pathToVlcExe = "C:\Program Files\VideoLAN\VLC\vlc.exe"

# Create one line item for each RTSP Camera
# *Required. Format: "name" = "rtsp://user:password@host/path"
$cameraStreams = [ordered]@{
"Driveway" = "rtsp://username:password@192.168.1.115/live"
"FrontDoor"= "rtsp://username:password@192.168.1.116/live"
"Backyard"= "rtsp://username:password@192.168.1.117/live"
}

# Set the path where VLC will write the write archive files
# *Only required if saving to file
$pathToSaveFiles = "G:\CameraStreams\"

# Stream transcode, either ogg or mp4
# *Will default to OGG if not set to "mp4"
$transcode = "mg4"

# Select which features to use. 1 is ON/True and 0 is OFF/False
# *Requires at least one of these set to 1. Default is Play in VLC
$playInVlc = 1
$saveToFile = 0
$convertToHttp = 0

# Set the network buffer in milliseconds. 
# *Will default to 1000 (1 second) if value not between 0 and 60000
$buffer = 1000

# Set the starting port for VLC to serve HTTP video streams
# *Will default to 8080
$port = 8080

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#!!!!!!!!!!!!!!! DON'T TOUCH ANYTHING BELOW HERE UNLESS YOU KNOW WHAT YOU ARE DOING !!!!!!!!!!!!!!!#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#

#Used as timestamp in saved files
$dateTime = Get-Date -Format "yyyMMddHHmmss"

#Ensure VLC.exe file exists
if (!(Test-Path $pathToVlcExe)) {
  Write-Warning "Can't find VLC at specific location: '$pathToVlcExe'. Please set 'pathToVlcExe'"
  break
}
Write-Host "Getting camera streams..."

#Set the transcoding information to pass in a VLC parameter
if ($convertToHttp -and ($transcode.ToUpper() -ne "OGG")) {
Write-Host "When converting stream to HTTP, OGG must be used. Changing transcode from $transcode to OGG"
$transcode = "OGG"
}
if ($transcode.ToUpper() -eq "MP4") {
    $trans = ":sout=#transcode{acodec=mpga,ab=128,channels=2,samplerate=44100,scodec=none}"
    $ext="mp4"
    Write-Host "Output will be MP4, vcodec is Original (WYZE uses AVC), acodec transcoded to mpga"
} else {
    $trans = ":sout=#transcode{vcodec=theo,vb=1024,scale=Auto,acodec=vorb,ab=60,channels=1,samplerate=44100,scodec=none}"
    $ext="ogg"
    Write-Host "Output will be OGG, vcodec transcoded to theo, acodec transcoded to vorb"
}
if ($playInVlc + $saveToFile + $convertToHttp -eq $false) {
    Write-Warning "No features selected. Opening streams in VLC"
    $playInVlc = 1
}
    
Write-Host

#For each camera stream...
$cameraStreams.Keys | % {
    Write-Host "Starting Camera | $_ "
    #Set the filename that this camera stream will be written to, if selected
    $saveFile="$($pathToSaveFiles.TrimEnd('\'))\$($_)_$dateTime.$ext"

    #Depending on selected options, set the destinations for this stream to output to
    $destinations = ":duplicate{"
    if ($playInVlc) {
        $destinations +="dst=display,"
        Write-Host "Showing $_ in VLC"
        }
    if ($saveToFile) {
        $destinations +="dst=file{dst=$saveFile,no-overwrite},"
        Write-Host "Saving $_ to $saveFile"
        }
    if ($convertToHttp) {
        $destinations +="dst=http{mux=ogg,dst=:$port },"
        Write-Host "Streaming $_ to http://localhost:$port/"
        }
    $destinations = $destinations.TrimEnd(",")
    $destinations += "}"
    
    #Define the entire string used for the output
    $parms = ":network-caching=$buffer $trans$destinations :sout-all :sout-keep"
    Write-Host "Output | $parms"
    Write-Host

    #Convert the parameter string into an array of values
    $prms = $Parms.Split(" ")

    #This is the execution. Vlc.exe will take the current camera steam and send it to the outputs defined by the parameters
    & "$pathToVlcExe" $cameraStreams[$_] $prms

    #Increment the port number used for the next HTTP output stream
    $port++
}
