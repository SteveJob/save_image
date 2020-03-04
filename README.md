# save_image

A new Flutter plugin.   OC + Kotlin  Language


## Permission

* ### Android

Add the following statement in `AndroidManifest.xml`:
```
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```
* ### iOS

Add the following statement in `Info.plist`
```
<key>NSPhotoLibraryUsageDescription</key>
<string>Modify the description of the permission you need here.</string>
```


# example
```dart
    var response = await Dio().get(url, options: Options(responseType: ResponseType.bytes));
    bool isSaveSuccess = await SaveImage.save(imageBytes: Uint8List.fromList(response.data));
```