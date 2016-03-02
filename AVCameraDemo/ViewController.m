//
//  ViewController.m
//  AVCameraDemo
//
//  Created by MADAO on 16/2/29.
//  Copyright © 2016年 MADAO. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<UIGestureRecognizerDelegate>
{
    CGFloat _beginScale;   /**开始缩放比例*/
    CGFloat _endScale;     /**结束缩放比例*/
}
/**后置摄像头*/
@property (nonatomic, strong) AVCaptureDevice *backCamera;
/**session: 数据传递Session*/
@property (nonatomic, strong) AVCaptureSession *session;
/**输入流*/
@property (nonatomic, strong) AVCaptureDeviceInput *input;
/**输出流*/
@property (nonatomic, strong) AVCaptureStillImageOutput *output;
/**预览*/
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _beginScale = 1.0;
    [self setupCamera];
    [self setupPreViewLayer];
    [self setupButtons];
    [self setupGestureRecognizer];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.session) {
        [self.session startRunning];
    }
}

- (void)setupCamera
{
    NSError *error = nil;
    
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPreset1920x1080;
    self.backCamera = [self getBackCamera];
    self.input = [[AVCaptureDeviceInput alloc] initWithDevice:self.backCamera error:&error];
    self.output = [[AVCaptureStillImageOutput alloc] init];
    self.output.outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:self.output]) {
        [self.session addOutput:self.output];
    }
}

- (void)setupButtons
{
    UIButton *flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    flashButton.frame = CGRectMake(15, 15, 100, 100);
    [flashButton setTitle:@"Flash" forState:UIControlStateNormal];
    [flashButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    flashButton.backgroundColor = [UIColor blackColor];
    [flashButton addTarget: self action:@selector(setupFlash) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:flashButton];
}

- (void)setupGestureRecognizer
{
    UIPinchGestureRecognizer *pinchGR = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoomCamera:)];
    pinchGR.delegate  = self;
    pinchGR.delaysTouchesBegan = YES;
    [self.view addGestureRecognizer:pinchGR];
}
/**获取摄像头*/
- (AVCaptureDevice *)cameraPosition:(AVCaptureDevicePosition)position
{
    for (AVCaptureDevice *device in [AVCaptureDevice devices]) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}
- (AVCaptureDevice *)getBackCamera
{
    return [self cameraPosition:AVCaptureDevicePositionBack];
}

/**设置图层*/
- (void)setupPreViewLayer
{
    if (self.previewLayer == nil) {
        self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        [self.previewLayer setBounds:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.previewLayer setFrame:self.view.frame];
        [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [self.view.layer addSublayer:self.previewLayer];
    }
}

/**任意位置点击拍照并保存*/
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    AVCaptureConnection *connection = [self.output connectionWithMediaType:AVMediaTypeVideo];
    
    [self.output captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        NSData *data = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [UIImage imageWithData:data];
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }];
}


#pragma mark - WidgetsActions
- (void)setupFlash
{
    if ([self.backCamera isFlashActive]) {
        [self setFlashMode:AVCaptureFlashModeOff];
    }
    else
    {
        [self setFlashMode:AVCaptureFlashModeOn];
    }
}
- (void)setFlashMode:(AVCaptureFlashMode)mode
{
    if ([self.backCamera isFlashModeSupported:mode]) {
        NSError *error = nil;
        if ([self.backCamera lockForConfiguration:&error]) {
//              /**Set Up TorchMode */
//            if (mode == AVCaptureFlashModeOn) {
//                [self.backCamera setTorchMode:AVCaptureTorchModeOn];
//            }
//            else
//            {
//                [self.backCamera setTorchMode:AVCaptureTorchModeOff];
//            }
            [self.backCamera setFlashMode:mode];
            [self.backCamera unlockForConfiguration];
        }
    }
}

#pragma mark - gestureRecognizer
- (void)zoomCamera:(UIPinchGestureRecognizer *)pinchGR
{
    CGFloat maxCameraScale = [[self.output connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor];
    _endScale = _beginScale * pinchGR.scale;
    if (_endScale < 1.f) {
        _endScale = 1.f;
    }
    else if (_endScale >= maxCameraScale)
    {
        _endScale = maxCameraScale;
    }
    else
    {
        [self.backCamera lockForConfiguration:nil];
        [self.backCamera setVideoZoomFactor:_endScale];
        [self.backCamera unlockForConfiguration];
    }
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    _beginScale = _endScale;
    return YES;
}
@end
