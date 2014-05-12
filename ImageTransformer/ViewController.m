//
//  ViewController.m
//  ImageTransformer
//
//  Created by Ian Griggs on 12/05/2014.
//  Copyright (c) 2014 The Lab. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    NSArray* _testImages;
}

@property (weak, nonatomic) IBOutlet UIImageView *startImageView;
@property (weak, nonatomic) IBOutlet UIImageView *endPortraitImageView;
@property (weak, nonatomic) IBOutlet UIImageView *endLandscapeImageView;
@property (weak, nonatomic) IBOutlet UIPickerView *imagePickerView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _testImages = @[@"up.jpg", @"down.jpg", @"left.jpg", @"right.jpg", @"up-mirrored.jpg", @"down-mirrored.jpg", @"left-mirrored.jpg", @"rightr-mirrored.jpg"];
    [self pickImage:_testImages[0]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)pickImage:(NSString*)imageName
{
    UIImage* startImage = [UIImage imageNamed:imageName];
    UIImage* startImageWithoutOrientation = [UIImage imageWithCGImage:startImage.CGImage];
    
    NSLog(@"start image : %d (%f,%f)", startImage.imageOrientation, startImage.size.width, startImage.size.height );
    NSLog(@"start image w/o orientation: %d (%f,%f)", startImageWithoutOrientation.imageOrientation, startImageWithoutOrientation.size.width, startImageWithoutOrientation.size.height );
    
    UIImage* endImage = [self normaliseOrientationForImage:startImage];
    
    [self startImageView].image = startImageWithoutOrientation;
    [self endPortraitImageView].image = endImage;
    [self endLandscapeImageView].image = endImage;
    
    NSLog(@"end image orientation: %d (%f,%f)", endImage.imageOrientation, endImage.size.width, endImage.size.height);

}

-(UIImage*)normaliseOrientationForImage:(UIImage*)originalImage
{
    // Get copy of image with orientation set to UIImageOrientationUp
    UIImage* image = [UIImage imageWithCGImage:originalImage.CGImage];
    
    CGSize imageSize = image.size;
    
    CGRect imageRect = CGRectIntegral(CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height));
    CGRect imageTransposedRect = CGRectMake(0.0f, 0.0f, imageSize.height, imageSize.width);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect drawRect = imageRect;
    
    switch (originalImage.imageOrientation) {
        case UIImageOrientationUp:
            break;
        case UIImageOrientationUpMirrored:
            transform = CGAffineTransformTranslate(transform, imageRect.size.width, 0.0f);
            transform = CGAffineTransformScale(transform, -1.0f, 1.0f);
            break;
        case UIImageOrientationDown:
            transform = CGAffineTransformTranslate(transform, imageRect.size.width, imageRect.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, 0.0f, imageRect.size.height);
            transform = CGAffineTransformScale(transform, 1.0f, -1.0f);
            break;
        case UIImageOrientationLeft:
            transform = CGAffineTransformTranslate(transform, imageRect.size.height, 0.0f);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            drawRect = imageTransposedRect;
            break;
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, imageRect.size.height, imageRect.size.width);
            transform = CGAffineTransformScale(transform, -1.0f, 1.0f);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            drawRect = imageTransposedRect;
            break;
        case UIImageOrientationRight:
            transform = CGAffineTransformTranslate(transform, 0.0f, imageRect.size.width);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            drawRect = imageTransposedRect;
            break;
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformScale(transform, -1.0f, 1.0f);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            drawRect = imageTransposedRect;
            break;
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                drawRect.size.width,
                                                drawRect.size.height,
                                                8,
                                                0,
                                                colorSpace,
                                                (CGBitmapInfo)kCGImageAlphaNoneSkipLast);

    
    CGContextConcatCTM(bitmap, transform);
    CGContextDrawImage(bitmap, imageRect, [image CGImage]);
    
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);
    CGColorSpaceRelease(colorSpace);
    
    return newImage;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_testImages count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _testImages[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"Picker picked %d", row);
    [self pickImage:_testImages[row]];
}


@end
