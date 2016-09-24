# Pre-work - *TipCalculator*

**ProTipShake** is a tip calculator application for iOS.

Submitted by: **Saurabh Patwardhan**

Time spent: **13** hours spent in total

## User Stories

The following **required** functionality is complete:

* [x] User can enter a bill amount, choose a tip percentage, and see the tip and total values.
* [x] Settings page to change the default tip percentage.

The following **optional** features are implemented:
* [x] UI animations
* [x] Remembering the bill amount across app restarts (if <10mins)
* [x] Using locale-specific currency and currency thousands separators.
* [x] Making sure the keyboard is always visible and the bill amount is always the first responder. This way the user doesn't have to tap anywhere to use this app. Just launch the app and start typing.

The following **additional** features are implemented:

- [x] Slider for picking tip amount.
- [x] Assign/Change color based on tip amount.
- [x] Light/dark color theme.
- [x] Shake Gesture handler which initiates a REST GET API call. 

## Video Walkthrough 

Here's a walkthrough of implemented user stories:

![Video Walkthrough](proTipShakeDemo.gif)

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes
- This code has been tested on iPhone 5s running only in portrait mode. 
- On the Settings Screen, I have added a shake gesture handler which makes a REST GET call to [The Internet Chuck Norris Database](http://www.icndb.com/) when the user shakes their phone. 
- Although it is not relevant to a tip calculator, I really wanted to explore gesture handling and network calls on iOS so I went ahead with this public API I found. 

## License

    Copyright [2016] [Saurabh Patwardhan]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
