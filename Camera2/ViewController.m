//
//  ViewController.m
//  Camera2
//
//  Created by 董志玮 on 2019/4/3.
//  Copyright © 2019 董志玮. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCapturePhotoOutput *stillImageOutput;
@property (nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.session = [AVCaptureSession new];
    self.session.sessionPreset = AVCaptureSessionPresetPhoto;
    AVCaptureDevice *backCamera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!backCamera) {
        NSLog(@"Unable to access back camera!");
        return;
    }
    
    NSError *error;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera
                                                                        error:&error];
    if (!error) {
    
        self.stillImageOutput = [AVCapturePhotoOutput new];
        
        if ([self.session canAddInput:input] && [self.session canAddOutput:self.stillImageOutput]) {
            
            [self.session addInput:input];
            [self.session addOutput:self.stillImageOutput];
            [self setupLivePreview];
        }
    }
    else {
        NSLog(@"Error Unable to initialize back camera: %@", error.localizedDescription);
    }
}
- (void)setupLivePreview {
    
    self.videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    if (self.videoPreviewLayer) {
        
        self.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        [self.previewView.layer addSublayer:self.videoPreviewLayer];
        
        dispatch_queue_t globalQueue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_async(globalQueue, ^{
            [self.session startRunning];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.videoPreviewLayer.frame = self.previewView.bounds;
            });
        });
    }
}
- (IBAction)didTakePhoto:(id)sender {
    AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettingsWithFormat:@{AVVideoCodecKey: AVVideoCodecTypeJPEG}];
    
    [self.stillImageOutput capturePhotoWithSettings:settings delegate:self];
}

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(nullable NSError *)error {
    
    NSData *imageData = photo.fileDataRepresentation;
    if (imageData) {
        UIImage *image = [UIImage imageWithData:imageData];
        // Add the image to captureImageView here...
        self.capturedImageView.image = image;
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                [self saveImageToDocumentDirectory:image];
            }
        }];
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureHandlerMethod:)];
        [self.capturedImageView setUserInteractionEnabled:YES];
        [self.capturedImageView addGestureRecognizer:tapRecognizer];

    }
}

-(void)saveImageToDocumentDirectory:(UIImage *)image{
    
    [[PHPhotoLibrary sharedPhotoLibrary]performChanges:^{
        PHAssetChangeRequest *addRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        addRequest.creationDate = [NSDate date];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            NSLog(@"Successfully Saved");
        }
        else{
            NSLog(@"Error saving image to photo library %@",error);
        }
    }];
    
}
-(void)gestureHandlerMethod:(UITapGestureRecognizer*)sender {

        
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];

}

@end
