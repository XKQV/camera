//
//  ViewController.h
//  Camera2
//
//  Created by 董志玮 on 2019/4/3.
//  Copyright © 2019 董志玮. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
@interface ViewController : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>
- (IBAction)didTakePhoto:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *previewView;
@property (strong, nonatomic) IBOutlet UIImageView *capturedImageView;



@end

