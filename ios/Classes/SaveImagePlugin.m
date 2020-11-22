#import "SaveImagePlugin.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>
#import <UIKit/UIKit.h>

@interface SaveImagePlugin ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@end

@implementation SaveImagePlugin  {
    FlutterResult _result;
    NSDictionary *_arguments;
    UIImagePickerController *_imagePickerController;
    UIViewController *_viewController;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel =
    [FlutterMethodChannel methodChannelWithName:@"aissz.com/save_image"
                                binaryMessenger:[registrar messenger]];
    UIViewController *viewController =
    [UIApplication sharedApplication].delegate.window.rootViewController;
    SaveImagePlugin *instance =
    [[SaveImagePlugin alloc] initWithViewController:viewController];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        _viewController = viewController;
        _imagePickerController = [[UIImagePickerController alloc] init];
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if (_result) {
        _result([FlutterError errorWithCode:@"multiple_request"
                                    message:@"Cancelled by a second request"
                                    details:nil]);
        _result = nil;
    }
    if ([@"saveAssetToGallery" isEqualToString:call.method]) {
        _result = result;
        _arguments = call.arguments;
        NSString* filePath = [_arguments objectForKey:@"path"] ;
        BOOL videoMark = [[_arguments objectForKey:@"videoMark"] boolValue];
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusRestricted) {
        } else if (status == PHAuthorizationStatusDenied) { 
        } else if (status == PHAuthorizationStatusAuthorized) {
            [self saveAsset:filePath isVideo:videoMark];
        } else if (status == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    [self saveAsset:filePath isVideo:videoMark];
                }
            }];
        }
    }
    else {
        result(FlutterMethodNotImplemented);
    }
}

-(void)saveAsset:(NSString *)assetPath isVideo:(BOOL)videoMark {
  __block NSString *localId;
  
  [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
    NSURL *fileUrl = [NSURL fileURLWithPath:assetPath];
    PHAssetChangeRequest* assetChangeRequest = nil;
    if (videoMark) {
      assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:fileUrl];
    } else {
      assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:fileUrl];
    }
    localId = [[assetChangeRequest placeholderForCreatedAsset] localIdentifier];
  } completionHandler:^(BOOL success, NSError *error) {
    if (success) {
      PHFetchResult* fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[localId] options:nil];
      PHAsset* asset = [fetchResult firstObject];
      [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
          self->_result([NSNumber numberWithBool:1]);
      }];
    } else {
      self->_result([NSNumber numberWithBool:0]);
   }
  }];
}

@end

