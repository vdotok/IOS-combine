# IOS-Chat
vdotok-IOS-chat

## Installation

### Requirements
##### System Requirements
* OS X 11.0 or later
* 8GB of ram memory
   
##### Development Requirements
* Xcode 12+
* [How to Install Xcode](https://www.freecodecamp.org/news/how-to-download-and-install-xcode/) Follow the guidelines in the link to install Xcode - we recommend to install Xcode from App Store 

### Installing Cocoapods
Open terminal and type command `pod --version` and hit enter. If command is not found then you don’t have cocoapods installed on your system.
#### Installing Cocoapods
* Type the following command in terminal `sudo gem install cocoapods` and hit enter
* After installation is complete, type command `pod --version` and hit enter to confirm installation is successful

### Project Signup and Project ID
Register at [VdoTok HomePage](https://vdotok.com) to get Authentication Token and Project ID

### Download iOS SDK Connect
Download **iOSSDKConnect** file from [VdoTok SDK](https://sdk.vdotok.com/IOS-SDKs/)

### Code Setup
*	Click on **Code** button 
*	From HTTPS section copy repo URL 
*	Open terminal
*	Go to Desktop directory by typing `cd Desktop` and hit enter
*	And then type `git clone paste_copied_ url` and hit enter
*	After cloning is complete, go to demo project’s root directory by typing `cd path_to_ cloned_project` and hit enter
*	Once inside the project’s root directory type `ls` (LS in small letters) and hit enter and you should see a file named **Podfile**
*	Type command `pod install` hit enter and wait until the process is complete
*	Copy the downloaded **iOSSDKConnect** to frameworks folder present in the root directory of the cloned project. See attached screenshots
<img width="618" alt="chat2" src="https://user-images.githubusercontent.com/2145411/123804142-673cc880-d906-11eb-877b-eb5712298812.png">

*	open .xcworkspace file by double clicking it
*	In the opened xcworkspace file, drag and drop the SDK present in the framework folder of the cloned project to the Frameworks folder of the main project, make sure to uncheck copy if needed option, see the attached screen shot
<img width="618" alt="chat3" src="https://user-images.githubusercontent.com/2145411/123804315-8b98a500-d906-11eb-8210-2da2c9a34c38.png">
<img width="618" alt="chat4" src="https://user-images.githubusercontent.com/2145411/123804328-8f2c2c00-d906-11eb-89c2-077388cfd025.png">

* Select the main project in xcworkspace file and in the general tab scroll to Frameworks, Libraries, and Embedded Content Section, make sure Embed & Sign is selected in Embed column next to our added SDK (.framework) 
<img width="618" alt="chat5" src="https://user-images.githubusercontent.com/2145411/123804428-a4a15600-d906-11eb-8eb2-381dcab9a931.png">

### Updating  Project ID and Authentication Token
Get Project ID and Authentication Token from [Admin Panel](https://vdotok.com)

Open .xcworkspace file in Xcode. In struct AuthenticationConstants Replace the values for PROJECTID  and AUTHTOKEN with your values

### Building On Device

To run on a real device, connect your device with MacBook pro and select your device from the dropdown menu in Xcode.
[Follow this link](https://codewithchris.com/deploy-your-app-on-an-iphone/) for details on how to run application on a real device



	     

