//
//  CameraViewController.m
//  VideoDemo
//
//  Created by VersionMismatch on 1/21/15.
//  Copyright (c) 2015 VersionMismatch. All rights reserved.
//
#import <AssetsLibrary/AssetsLibrary.h>
#import <GLKit/GLKit.h>
#import "CameraViewController.h"
#import "PBJVision.h"

@interface CameraViewController () <UIGestureRecognizerDelegate, PBJVisionDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet UIView *previewView;
@property (nonatomic, strong) IBOutlet UIButton *flipCameraButton;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, strong) ALAssetsLibrary *assetLibrary;

@property (nonatomic, strong) __block NSDictionary *currentVideo;


@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _assetLibrary = [[ALAssetsLibrary alloc] init];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    

    _previewView.backgroundColor = [UIColor blackColor];
    _previewLayer = [[PBJVision sharedInstance] previewLayer];
    _previewLayer.frame = _previewView.bounds;
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [_previewView.layer addSublayer:_previewLayer];
    [_previewView bringSubviewToFront:_flipCameraButton];
    [self setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Buttons

- (IBAction)handleFlipButton:(UIButton *)button
{
    PBJVision *vision = [PBJVision sharedInstance];
    vision.cameraDevice = vision.cameraDevice == PBJCameraDeviceBack ? PBJCameraDeviceFront : PBJCameraDeviceBack;
}

#pragma mark - Gesture Recognizer Delegate
- (IBAction)handleLongPressGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
                [[PBJVision sharedInstance] startVideoCapture];
                _flipCameraButton.hidden = YES;
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            //TODO Block the UI until the video is saved.
            self.flipCameraButton.hidden = NO;
            [[PBJVision sharedInstance] endVideoCapture];
            
            break;
        }
        default:
            break;
    }
}

#pragma mark PJVisionDelegate

- (void)vision:(PBJVision *)vision capturedVideo:(NSDictionary *)videoDict error:(NSError *)error
{
    if (error && [error.domain isEqual:PBJVisionErrorDomain] && error.code == PBJVisionErrorCancelled) {
        NSLog(@"recording session cancelled");
        return;
    } else if (error) {
        NSLog(@"encounted an error in video capture (%@)", error);
        return;
    }
    
    _currentVideo = videoDict;
    
    NSString *videoPath = [_currentVideo  objectForKey:PBJVisionVideoPathKey];
    [_assetLibrary writeVideoAtPathToSavedPhotosAlbum:[NSURL URLWithString:videoPath] completionBlock:^(NSURL *assetURL, NSError *error1) {
        UIAlertView *alert;
        if (!assetURL)
             alert = [[UIAlertView alloc] initWithTitle: @"Video Not Saved!" message:[NSString stringWithFormat:@"Video was not saved to camera roll, error: %@", [error1 localizedDescription]] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];

        else
        {
            alert = [[UIAlertView alloc] initWithTitle: @"Video Saved!" message: @"Saved to the camera roll." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            //add key a extern const
            NSMutableArray *urlsArray = [NSMutableArray arrayWithArray:[defaults objectForKey:@"storedVideos"]];

            if (!urlsArray)
                [defaults setObject:[NSArray arrayWithObject:[assetURL absoluteString]] forKey:@"storedVideos"];
            else
            {
                [urlsArray addObject:[assetURL absoluteString]];
                [defaults setObject:[NSArray arrayWithArray:urlsArray] forKey:@"storedVideos"];
                [defaults synchronize];
            }
            
        }
        [alert show];
    }];
}

#pragma mark - Video
- (void)setup
{
    
    PBJVision *vision = [PBJVision sharedInstance];
    vision.delegate = self;
    vision.cameraMode = PBJCameraModeVideo;
    vision.cameraOrientation = PBJCameraOrientationPortrait;
    vision.focusMode = PBJFocusModeContinuousAutoFocus;
    vision.outputFormat = PBJOutputFormatSquare;
    
    [vision startPreview];
}


@end
