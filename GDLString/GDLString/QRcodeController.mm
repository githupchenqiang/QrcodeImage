//
//  QRcodeController.h
//  GDLString
//
//  Created by QAING CHEN on 16/10/25.
//  Copyright © 2016年 QiangChen. All rights reserved.
//

#import "QRcodeController.h"
#import "ViewController.h"
static const char *kScanQRCodeQueueName = "ScanQRCodeQueue";

@interface QRcodeController ()<AVCaptureMetadataOutputObjectsDelegate>

@end

@implementation QRcodeController

- (void)viewDidLoad {
    [super viewDidLoad];
    _qrResult = NO;
    
    [self startScan];
    
    CGSize size = [[UIScreen mainScreen] bounds].size;
    int c_x = size.width/2;
    int c_y = size.height/2;
    int roi = 160/2;
    
    UIView *top = [[UIView alloc]initWithFrame:CGRectMake(0, 0, size.width, c_y - roi)];
    top.backgroundColor = [UIColor blackColor];
    top.alpha = 0.8;
    [self.view addSubview:top];
    
    UIView* left = [[UIView alloc] initWithFrame:CGRectMake(0, c_y - roi, c_x - roi, 2*roi)];
    left.backgroundColor = [UIColor blackColor];
    left.alpha = 0.8;
    [self.view addSubview:left];
    
    UIView* right = [[UIView alloc] initWithFrame:CGRectMake(c_x + roi , c_y-roi, c_x - roi, 2*roi)];
    right.backgroundColor = [UIColor blackColor];
    right.alpha = 0.8;
    [self.view addSubview:right];
    
    UIView* bottom = [[UIView alloc] initWithFrame:CGRectMake(0, c_y + roi, size.width, c_y - roi)];
    bottom.backgroundColor = [UIColor blackColor];
    bottom.alpha = 0.8;
    [self.view addSubview:bottom];

    
}

- (void)startScan
{
    NSError * error;
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    
    if ([captureDevice lockForConfiguration:nil]) {
        //对焦模式，自动对焦
        if (captureDevice && [captureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            [captureDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        else if(captureDevice && [captureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]){
            [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        
        // 自动白平衡
        if (captureDevice && [captureDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
            captureDevice.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
        }
        else if (captureDevice && [captureDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            captureDevice.whiteBalanceMode = AVCaptureWhiteBalanceModeAutoWhiteBalance;
        }
        
        if (captureDevice && [captureDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            captureDevice.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        }
        else if (captureDevice && [captureDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
            captureDevice.exposureMode = AVCaptureExposureModeAutoExpose;
        }
        
        [captureDevice unlockForConfiguration];
    }
    
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return ;
    }
    
    // 创建会话
    _capetureSession = [[AVCaptureSession alloc] init];
    // 添加输入流
    [_capetureSession addInput:input];
    // 初始化输出流
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    // 添加输出流
    [_capetureSession addOutput:captureMetadataOutput];
    
    // 创建dispatch queue.
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create(kScanQRCodeQueueName, NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    // 设置元数据类型 AVMetadataObjectTypeQRCode
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    //    captureMetadataOutput.rectOfInterest=CGRectMake(0.25,025,0.5, 0.5);
    // 创建输出对象
    _PreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_capetureSession];
    [_PreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_PreviewLayer setFrame:self.view.layer.bounds];
    [self.view.layer addSublayer:_PreviewLayer];
    
    [_capetureSession startRunning];
    
}
- (void)stopScanQRCode {
    [_capetureSession stopRunning];
    _capetureSession = nil;
    
    [_PreviewLayer removeFromSuperlayer];
    _PreviewLayer = nil;
}

- (void)handleScanResult:(NSString *)result
{
    
    NSLog(@"===%@",result);
    
    [self stopScanQRCode];
    if (_qrResult) {
        return;
    }
    _qrResult = YES;
    
    if ([self.pvc isKindOfClass:[ViewController class]]) {
        ViewController *contr = [[ViewController alloc]init];
        contr.valueNumber.text = result;
        
    }
    
    [self.navigationController popToViewController:self.pvc animated:YES];
    
    
    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,int64_t(2 * NSEC_PER_SEC) ),dispatch_get_main_queue(), ^{
                [self performSelectorOnMainThread:@selector(handleScanResult:) withObject:metadataObj.stringValue waitUntilDone:NO];
            });
        }
    }
}

- (void)MainSeleted:(id)seleted
{
    
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self stopScanQRCode];
    [self.navigationController popViewControllerAnimated:YES];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
