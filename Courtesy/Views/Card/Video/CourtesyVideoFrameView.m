//
//  CourtesyVideoFrameView.m
//  Courtesy
//
//  Created by Zheng on 3/6/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAssetImageGenerator.h>
#import <AVFoundation/AVAsset.h>
#import <AVKit/AVKit.h>
#import "CourtesyVideoFrameView.h"

@implementation CourtesyVideoFrameView

- (void)setVideoURL:(NSURL *)videoURL {
    _videoURL = videoURL;
    UIImage *previewImage = [self thumbnailImageForVideo:videoURL atTime:0.0];
    [self setCenterImage:previewImage];
}

- (UIImage*)thumbnailImageForVideo:(NSURL *)videoURL
                            atTime:(NSTimeInterval)time {
    CYLog(@"%@", videoURL);
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:self.videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, asset.duration.timescale) actualTime:NULL error:&thumbnailImageGenerationError];
    
    if (!thumbnailImageRef || thumbnailImageGenerationError) {
        NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
        return nil;
    }
    
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef] : nil;
    if (!thumbnailImage) {
        return nil;
    }
    
    CGRect targetRect = CGRectMake(0, 0, thumbnailImage.size.width, thumbnailImage.size.width * (9.0 / 16));
    CGImageRelease(thumbnailImageRef);
    UIImage *croppedImage = [thumbnailImage imageByCropToRect:targetRect];
//    UIImage *maskImage = [[UIImage imageNamed:@"53-play-center"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    
//    UIGraphicsBeginImageContext(croppedImage.size);
//    [croppedImage drawInRect:CGRectMake(0, 0, croppedImage.size.width, croppedImage.size.height)];
//    [maskImage drawInRect:CGRectMake((croppedImage.size.width - maskImage.size.width) / 2, (croppedImage.size.height - maskImage.size.height) / 2, maskImage.size.width, maskImage.size.height)];
//    
//    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    
    return croppedImage;
}

- (NSString *)labelHolder {
    return @"视频描述";
}

- (NSArray *)optionButtons {
    return @[[self deleteBtn],
             [self editBtn],
             [self playBtn]];
}

- (UIImageView *)centerBtn {
    if (!_centerBtn) {
        _centerBtn = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        _centerBtn.center = CGPointMake(self.centerImageView.frame.size.width / 2, self.centerImageView.frame.size.height / 2);
        _centerBtn.backgroundColor = [UIColor clearColor];
        _centerBtn.tintColor = [UIColor whiteColor];
        _centerBtn.userInteractionEnabled = YES;
        _centerBtn.image = [[UIImage imageNamed:@"53-play-center"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UITapGestureRecognizer *playGesture = [[UITapGestureRecognizer alloc] initWithActionBlock:^(UITapGestureRecognizer *g) {
            [self playVideo];
        }];
        [_centerBtn addGestureRecognizer:playGesture];
    }
    return _centerBtn;
}

- (UIImageView *)playBtn {
    if (!_playBtn) {
        _playBtn = [[UIImageView alloc] initWithFrame:CGRectMake(kImageFrameBtnBorderWidth + (kImageFrameBtnWidth + kImageFrameBtnInterval) * 2, kImageFrameBtnBorderWidth, kImageFrameBtnWidth, kImageFrameBtnWidth)];
        _playBtn.backgroundColor = [UIColor clearColor];
        _playBtn.image = [UIImage imageNamed:@"52-unbrella-play"];
        _playBtn.alpha = 0;
        _playBtn.hidden = YES;
        _playBtn.userInteractionEnabled = YES;
        UITapGestureRecognizer *playGesture = [[UITapGestureRecognizer alloc] initWithActionBlock:^(UITapGestureRecognizer *g) {
            [self playVideo];
        }];
        [_playBtn addGestureRecognizer:playGesture];
    }
    return _playBtn;
}

- (void)playVideo {
    AVPlayer *player = [[AVPlayer alloc] initWithURL:_videoURL];
    AVPlayerViewController *movie = [[AVPlayerViewController alloc] init];
    if (!player || !movie) {
        return;
    }
    [movie setPlayer:player];
    if (![[self delegate] isKindOfClass:[UIViewController class]]) {
        return;
    }
    UIViewController *superViewController = (UIViewController *)self.delegate;
    [superViewController presentViewController:movie animated:YES completion:^{
        [player play];
    }];
}

@end
