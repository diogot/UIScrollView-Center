//
//  ViewController.m
//  UIScrollView-Center
//
//  Created by Diogo Tridapalli on 9/20/15.
//  Copyright © 2015 Diogo Tridapalli. All rights reserved.
//

#import "ViewController.h"

static CGFloat const kMargin = 5.;
static CGFloat const kMaxZoomFactor = 3.;

@interface ViewController () <UIScrollViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, readonly) UIImageView *imageView;

@property (nonatomic, readonly) UIEdgeInsets scrollViewDefaultInset;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frame = self.view.bounds;
    
    _scrollView = [self createScrollView];
    _scrollView.frame = frame;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:_scrollView];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(10, 50, 150, 50); // lazy ¯\_(ツ)_/¯
    [button setTitle:NSLocalizedString(@"Pick image", ) forState:UIControlStateNormal];
    [button addTarget:self action:@selector(pickImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (UIScrollView *)createScrollView
{
    _imageView = [UIImageView new];
    _imageView.contentMode = UIViewContentModeCenter;
    
    UIScrollView *scrollView = [UIScrollView new];
    
    scrollView.alwaysBounceHorizontal = YES;
    scrollView.alwaysBounceVertical = YES;
    scrollView.delegate = self;
    [scrollView addSubview:_imageView];
    
    return scrollView;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGFloat topInset = self.topLayoutGuide.length;
    CGFloat bottomInset = self.bottomLayoutGuide.length;
    
    _scrollViewDefaultInset = UIEdgeInsetsMake(topInset,
                                               0,
                                               bottomInset,
                                               0);
}

- (void)updateWithImage:(UIImage *)image
{
    UIScrollView *scrollView = self.scrollView;
    UIImageView *imageView = self.imageView;
    
    imageView.image = image;
    CGSize imageSize = image.size;
    CGRect imageFrame = CGRectMake(0, 0, imageSize.width, imageSize.height);
    
    imageView.frame = imageFrame;
    scrollView.contentSize = imageSize;
    
    CGRect scrollViewFrame = scrollView.frame;
    
    // Set Inset
    UIEdgeInsets insets = self.scrollViewDefaultInset;
    insets = [self insetsForContentFrame:imageFrame
               insideScrollViewWithFrame:scrollViewFrame
                       withDefaultInsets:insets];
    scrollView.contentInset = insets;
    
    // Set Zoom
    CGSize scrollViewSize = CGSizeMake(CGRectGetWidth(scrollViewFrame) - insets.left - insets.right,
                                       CGRectGetHeight(scrollViewFrame) - insets.top - insets.bottom);
    CGFloat xMinZoomScale = scrollViewSize.width/(imageSize.width + 2. * kMargin);
    CGFloat yMinZoomScale = scrollViewSize.height/(imageSize.height + 2. * kMargin);
    CGFloat minimumZoomScale = MIN(xMinZoomScale, yMinZoomScale);
    scrollView.minimumZoomScale = minimumZoomScale;
    scrollView.maximumZoomScale = minimumZoomScale * kMaxZoomFactor;
    
    // Fit on screen
    scrollView.zoomScale = minimumZoomScale;
}

- (UIEdgeInsets)insetsForContentFrame:(CGRect)contentFrame
            insideScrollViewWithFrame:(CGRect)scrollViewFrame
                    withDefaultInsets:(UIEdgeInsets)insets
{
    CGSize contentSize = contentFrame.size;
    CGSize scrollViewSize = CGSizeMake(CGRectGetWidth(scrollViewFrame) - insets.left - insets.right,
                                       CGRectGetHeight(scrollViewFrame) - insets.top - insets.bottom);
    CGFloat margin = kMargin;
    
    CGFloat xInset = MAX((scrollViewSize.width - contentSize.width)/2., margin);
    CGFloat yInset = MAX((scrollViewSize.height - contentSize.height)/2., margin);
    
    insets.left += xInset;
    insets.right += xInset;
    insets.top += yInset;
    insets.bottom += yInset;
    
    return insets;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    UIEdgeInsets insets = self.scrollViewDefaultInset;
    
    insets = [self insetsForContentFrame:self.imageView.frame
               insideScrollViewWithFrame:scrollView.frame
                       withDefaultInsets:insets];
    
    scrollView.contentInset = insets;
}

#pragma mark - Image picker

- (void)pickImage
{
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker
    didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    [self updateWithImage:chosenImage];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
