# test-ios-like-a-boss
This repository contains sample code demonstrating how you can test your iOS applications in an automated way. There are two samples. ios-testing contains both automated functional tests and automated image comparison tests. DownloadTileCacheSample was taken from our [iOS samples](https://github.com/Esri/arcgis-runtime-samples-ios/tree/master/DownloadTileCacheSample) repo and ported to Quartz since it was written for 10.2.5

The ```master``` branch of this repository contains test projects you can use to get you started with testing.

## Requirements
[ArcGIS Runtime SDK for iOS](https://developers.arcgis.com/en/ios/) (Requires ArcGIS for Developers account; free to sign up)
You need Quartz release of the API. 10.2.x release don't have exportImage method on mapView. 

For Swift : 
* XCode 7.0 (or higher)
* iOS 8 SDK (or higher)

## Instructions

1. Get the code in this repository. Don't know how? [Get started here.](http://htmlpreview.github.com/?https://github.com/Esri/esri.github.com/blob/master/help/esri-getting-to-know-github.html)
2a. Open the ```ios-testing/ios-testing.xcodeproj``` file to open automated functional and image comparison tests.
2b. Open the ```downloadTileCacheSample/DownloadTileCache.xcodeproj``` file to open XCode automated UI samples.
3. Choose a Target and Device/Simulator combination from the Scheme menu and select Run tests (cmd + U) to run tests. Image comparison tests will need expected images on your test machine before they will pass. 


##Additional Resources

* Want to start a new project? [Setup](https://developers.arcgis.com/en/ios/info/install.htm) your dev environment
* New to the API? Explore the documentation : [Guide](http://developers.arcgis.com/en/ios/guide/introduction.htm) | [API Reference](http://developers.arcgis.com/en/ios/api-reference/index.htm)
* Got a question? Ask the community on our [forum](http://forums.arcgis.com/forums/78-ArcGIS-for-iOS-SDK)

## Licensing
Copyright 2013 Esri

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

A copy of the license is available in the repository's [license.txt]( https://raw.github.com/Esri/arcgis-runtime-samples-ios/master/license.txt) file.

[](Esri Tags: ArcGIS Runtime iOS SDK Samples)
[](Esri Language: Objective-C, Swift)
