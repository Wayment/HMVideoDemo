//
//  ViewController.m
//  HMVideoDemo
//
//  Created by Huiming on 16/11/3.
//  Copyright © 2016年 AppGame. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

#define HMScreenWidth   [UIScreen mainScreen].bounds.size.width
#define HMScreenHeight  [UIScreen mainScreen].bounds.size.height

@interface ViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>

/// 摄像头input
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;
/// 捕获的视频流
@property (nonatomic, strong) AVCaptureSession *captureSession;
/// 预览的图层
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
/// 图片探测器
@property (nonatomic, strong) CIDetector *detector;

@property (nonatomic, strong) CIContext *ciContext;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.ciContext = [[CIContext alloc] initWithOptions:nil];
    
    // 获取摄像头设备  iSO:AVCaptureDeviceDiscoverySession
    AVCaptureDevice *capDevice = nil;
    NSArray *capDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in capDevices) {
        if (device.position == AVCaptureDevicePositionFront) {
            capDevice = device;
            break;
        }
    }
    // 获取摄像头input
    self.deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:capDevice error:nil];
    if (!self.deviceInput) {
        return;
    }
    
    // 设置捕获视频流的大小
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession setSessionPreset:AVCaptureSessionPresetiFrame960x540];
    [self.captureSession addInput:self.deviceInput];
    
    // 预览
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    self.previewLayer.frame = CGRectMake(0, 0, HMScreenWidth, HMScreenWidth);
    self.previewLayer.backgroundColor = [UIColor lightGrayColor].CGColor;
    [self.view.layer addSublayer:self.previewLayer];
    
    // 监听流
    AVCaptureVideoDataOutput *videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    [self.captureSession addOutput:videoOutput];
    [videoOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    

    // 开启流
    [self.captureSession startRunning];
}

#pragma mark - <AVCaptureVideoDataOutputSampleBufferDelegate>
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    UIImage *image = [UIImage imageNamed:@"common_icon_living"];
    CIImage *cImage = [CIImage imageWithCGImage:image.CGImage];
    [self.ciContext render:cImage toCVPixelBuffer:pixelBuffer];
}

@end
