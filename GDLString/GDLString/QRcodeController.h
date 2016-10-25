//
//  QRcodeController.h
//  GDLString
//
//  Created by QAING CHEN on 16/10/25.
//  Copyright © 2016年 QiangChen. All rights reserved.


#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface QRcodeController : UIViewController
{
    BOOL                _qrResult;
    AVCaptureSession    *_capetureSession;
    AVCaptureVideoPreviewLayer *_PreviewLayer;
    
    
}

@property (nonatomic,copy)void(^backBlock)(void);
@property (nonatomic, retain)   UIViewController* pvc;
@end
