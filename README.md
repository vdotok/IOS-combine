# IOS-combine
VDOTOK-IOS-combine Chat/Audio/Video/Broadcast

## Prerequisite
* To begin, you must possess a good understanding of [Broadcast Extensions](https://developer.apple.com/app-extensions), [AppGroupIDs](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_security_application-groups?language=objc), and [ReplayKit](https://developer.apple.com/documentation/replaykit).
## Requirements

##### Development Requirements
* Xcode 13.4.1 or latest version
* [Click here](https://developer.apple.com/xcode/resources/) to download Xcode on your Macbook
 
##### System Requirements
* MacOS as compatible with xcode version
* 8GB of RAM memory
   


## Installation
### Installing Cocoapods
Open **Terminal** and type command `pod --version` and hit **Enter**.

If command is not found then you don’t have Cocoapods installed on your system. To install Cocoapods, here are the steps to follow:
#### Installing Cocoapods
* Type the following command in **Terminal** `sudo gem install cocoapods` and hit **Enter**
* If you face this issue **ERROR: Failed to build gem native extension**, then run `brew install cocoapods`
* After installation is complete, type command `pod --version` and hit **Enter** to confirm installation is successful

### Project Signup and Project ID
Register at [VdoTok HomePage](https://vdotok.com) to get **TENANT TESTING SERVER** and **Project ID**

### Code Setup
*    On VdoTok Github repo,click on **Code** button 
*    From HTTPS section, copy **repo URL** 
*    Open **Terminal**
*    Go to Desktop **Directory** by typing `cd Desktop` and hit **Enter**
*    And then type `git clone https://github.com/vdotok/IOS-combine.git` and hit **Enter**
*    After cloning is complete, go to **Cloned project’s root directory** by typing `cd path_to_ cloned_project` and hit **Enter**
*    Once inside the project’s root directory type `ls` (LS in small letters) and hit **Enter**.
    You should be able to see a file named **Podfile**
*    Type command `pod install` hit **Enter** wait until the process is complete
*    Once the process is completed it should look like following

   <img width="500" alt="Screenshot 2022-08-16 at 12 11 20 PM" src="https://user-images.githubusercontent.com/111276411/184857546-2740e1e4-b041-450e-a0f3-ae759c270053.png">
   
*    If you face issue below,execute this command in terminal `gem install --user-install ffi -- --enable-libffi-alloc` ,then run `pod install` 
      
<img width="500" alt="Screen Shot 2022-08-22 at 5 10 37 PM" src="https://user-images.githubusercontent.com/111276411/186087301-81952093-eabf-4c3a-85f9-21f34dbd9b3f.png">


### Updating  Project ID and Authentication Token

*  Get **Project ID** and **TENANT TESTING SERVER** from [Admin Panel](https://console.vdotok.com/login) 
*  In cloned directory, double-click to open **.xcworkspace file** in Xcode
*  In struct AuthenticationConstants (iOS-combine -> common -> constants), replace the values for **PROJECTID** and **TENANTSERVER** ( without `https://` ) with your values

### Set up Bundle identifier & App groups
* Go to your **Main Target->Signing and Capabilities**
* Select your Team and setup your bundle identifier like `com.company.appname` for all the targets
* Bundle identifier should be unique for all targets for example.
   `com.company.appname`
   `com.company.appname.ScreenShare`
   `com.company.appname.ScreenShareSetupUI`
* To establish a connection between your main “Main Target” and “Extension Target”, add **appgoups** in your all targets
* Go to your **Main Target->Signing and Capabilities->Capabilities(+ icon)**
* Tap on the **App groups Icon** and create your **Group ID**
<img width="500" alt="Screenshot 2022-08-16 at 12 12 05 PM" src="https://user-images.githubusercontent.com/111276411/184847078-269d6e1d-e5c7-4ac8-8ea5-38c880a3305e.png">

* Now checkmark the box to enable **Group ID** and tap on Refresh icon 
* **App Group ID** must be kept same for all targets
* Repeat the above action for **Screen Share**, and **Screenshare Utility Target**
* Now go to AppsGroup struct **(iOS-combine -> common -> constants)**, replace the values for **APP_GROUP** and **SCREEN_SHARE_PREFERED_EXTENSION** with your **App Group Identifier** and **Screenshare Target's Bundle Identifier** respectively

### Building On Device
*Please be noted that iOSSDKStreaming does not work for iOS Simulator*

To run on a real device:

   *    Connect your device with MacBook 
   *    Select your device from the run destination menu in toolbar
   *    Click on play button on xcode toolbar
   *    For details on how to run application on a real device, please [click here](https://codewithchris.com/deploy-your-app-on-an-iphone/) to follow instructions.



         
