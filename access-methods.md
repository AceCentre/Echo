# Access Methods

Echo allows for multiple access methods.

{% embed url="https://youtu.be/i5KYUj7epeo?si=blhUycVauqQjhvCT&t=110" %}

## Swipe Gestures

You can swipe up, down, left or right. You must do the swipe across the main part of the screen for it to register.&#x20;

Swipes trigger the following actions:

* Up - Go back/up in the list
* Down - Go forward/down in the list
* Right - Select the current item
* Left - Remove the previous character
* Tap - Select the current item

You can enable and disable the swipes in the settings

## On Screen Arrows

You can use the on screen arrows to control Echo. You can drag the arrows about the screen to put them somewhere you find convenient.

Arrows trigger the following actions:

* Up - Go back/up in the list
* Down - Go forward/down in the list
* Right - Select the current item
* Left - Remove the previous character

You can enable and disable the arrows in the settings

## External Switches

Echo allows you to use external switches to control the app. To add a new switch go to your access settings and then click add a new switch. You can then click 'detect switch' which will then listen for you to press your switch. This registers the switch and then you can assign it an action.

Possible actions are:

* None - This can be used if you want to register a switch but not have the switch trigger an action
* Go to the next item
* Go to the previous item
* Select the currently selected item
* Delete the last inputted letter
* Clear all the inputted text
* Start scanning from the current item, scanning must be enabled
* Quickly scan through the items - This is only available when holding the switch

#### Speech Case

If you are using a ['speech case'](https://uk.tobiidynavox.com/products/speech-case) from TD you need to make sure that the toggle on the side of the case is in 'touch' mode. Once you have done that you can then setup the switches inside of Echo the same way you would any other switch.

## Game Controller

Echo also supports the use of Game Controllers to control the app. [Read Apples official guide on how to connect your game controller to your device.](https://support.apple.com/en-gb/111099) Once you have connected your controller to your device it will appear in the access methods section of the Echo settings. You can then map each button on the controller to do any action you want inside of Echo.&#x20;

A game controller has all the same actions as external switches.

## Facial Gestures

Echo includes advanced facial gesture recognition that allows users with limited mobility to control the app using facial movements instead of touch input. This accessibility feature uses your device's front-facing camera and Apple's ARKit technology to detect specific facial gestures.

### Device Requirements

Facial gesture recognition requires a compatible device with face tracking capability:

* **iPhone X or later** (including Pro models with TrueDepth camera)
* **iPhone XR, 11, 12 mini, 13 mini, 14, 15** (using Neural Engine-based tracking)
* **iPad Pro with TrueDepth camera**
* **iPad Air (4th generation and later)**
* **iPad (9th generation and later)**

### Getting Started

1. **Enable Facial Gestures**: Go to Settings → Access Options → Enable "Facial Gestures"
2. **Grant Camera Permission**: Echo will request camera access for gesture detection
3. **Configure Gestures**: Tap "Facial Gesture Switches" to set up your gestures
4. **Test Your Setup**: Use the "Test Gesture" feature to verify detection

### Available Gestures

Echo supports a wide range of facial gestures organized by anatomical regions:

#### Eye Gestures
* Left Eye Blink
* Right Eye Blink
* Either Eye Blink
* Left Eye Open (sustained)
* Right Eye Open (sustained)
* Either Eye Open (sustained)

#### Eyebrow Gestures
* Brow Down Left
* Brow Down Right
* Brow Inner Up (surprise expression)
* Brow Outer Up Left
* Brow Outer Up Right

#### Mouth and Jaw Gestures
* Jaw Open
* Jaw Forward
* Jaw Left/Right
* Mouth Close
* Mouth Smile Left/Right
* Mouth Frown Left/Right
* Mouth Pucker
* Mouth Funnel
* Various other mouth movements

#### Cheek and Nose Gestures
* Cheek Puff
* Cheek Squint Left/Right
* Nose Sneer Left/Right

#### Head Movement Gestures
* Head Nod Up/Down
* Head Shake Left/Right
* Head Tilt Left/Right

#### Gaze Direction
* Look Up/Down/Left/Right

### Gesture Configuration

Each facial gesture can be configured with:

* **Threshold**: How pronounced the gesture needs to be to trigger (0-100%)
* **Hold Duration**: How long to hold the gesture for "hold" actions
* **Tap Action**: What happens with a quick gesture
* **Hold Action**: What happens when holding the gesture

### Auto-Detection Feature

Echo includes an intelligent auto-detection system:

1. **Start Auto-Detection**: Choose "Auto-Select Gesture" when adding a new gesture
2. **Follow Instructions**: Position your face in the camera view
3. **Perform Gesture**: Make your desired gesture when prompted
4. **Automatic Selection**: Echo will identify and configure the best-matching gesture

### Gesture Actions

Facial gestures can trigger the same actions as other access methods:

* Go to the next item
* Go to the previous item
* Select the currently selected item
* Delete the last inputted letter
* Clear all the inputted text
* Start scanning from the current item
* Quick scan through items (hold actions)

### Privacy and Security

* **On-Device Processing**: All facial gesture recognition happens locally on your device
* **No Data Storage**: Facial data is processed in real-time and immediately discarded
* **No Data Sharing**: No facial information is transmitted to servers or shared with third parties
* **User Control**: You can disable facial gestures at any time in settings

### Tips for Best Results

* **Good Lighting**: Ensure adequate lighting on your face
* **Stable Position**: Keep your device stable and at a comfortable viewing angle
* **Clear Gestures**: Make distinct, deliberate movements
* **Adjust Thresholds**: Fine-tune sensitivity settings for your needs
* **Practice**: Use the test feature to familiarize yourself with gesture detection

### Troubleshooting

* **Gestures Not Detected**: Check camera permissions and lighting conditions
* **False Triggers**: Increase gesture thresholds in settings
* **Inconsistent Detection**: Ensure stable device positioning and clear facial view
* **Performance Issues**: Close other apps that might be using the camera