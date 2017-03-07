//
//  RXPicClipViewController.m
//  DomePhoto
//
//  Created by iXcoder on 2017/3/1.
//  Copyright © 2017年 easylife. All rights reserved.
//

#import "RXPicClipViewController.h"
#import <WebKit/WebKit.h>

@interface RXPicClipViewController ()<UIScrollViewDelegate, UIWebViewDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) UIScrollView *ctntView;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) CAShapeLayer *carvedLayer;

@end

@implementation RXPicClipViewController

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor blackColor];
    self.view.opaque = YES;
    self.imgView.image = self.image;
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelEditAction:)];
    cancel.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *confirm = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(onConfirmEditAction:)];
    confirm.tintColor = [UIColor whiteColor];
    
    toolbar.items = @[cancel, space, confirm];
    toolbar.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height - 22);
    [self.view addSubview:toolbar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CGFloat ratio = self.whRatio;
    if (ratio == 0 || ratio == CGFLOAT_MAX) {
        ratio = 16. / 9.;
    }
    self.whRatio = ratio;
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGSize imgSize = self.image.size;
    CGSize ctntSize = self.ctntView.frame.size;
    
    CGFloat compressRatio = MIN(ctntSize.width / imgSize.width
                                , ctntSize.height / imgSize.height);
    
    CGFloat imgViewWidth = imgSize.width * compressRatio;
    CGFloat imgViewHeight = imgSize.height * compressRatio;
    
    CGFloat clipWidth = ctntSize.width;
    CGFloat clipHeight = clipWidth / self.whRatio;
    if (imgViewHeight < clipHeight) {
        CGFloat scale = clipHeight / imgViewHeight;
        imgViewHeight = clipHeight;
        imgViewWidth *= scale;
    }

    self.imgView.frame = CGRectMake(0.
                                    , 0.
                                    , imgViewWidth
                                    , imgViewHeight);
    self.ctntView.contentSize = CGSizeMake(imgViewWidth, imgViewHeight);
    
    CGFloat xInset = (ctntSize.width - clipWidth) / 2.;
    CGFloat yInset = (ctntSize.height - clipHeight) / 2.;
    self.ctntView.contentInset = UIEdgeInsetsMake(yInset, xInset, yInset, xInset);

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
}

#pragma mark - self defined methods

- (void)showCarvedWithRect:(CGRect)rect
{
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 44)];
    
    UIBezierPath *pLine = [UIBezierPath bezierPathWithRect:rect];

    [path appendPath:[pLine bezierPathByReversingPath]];
    
    self.carvedLayer.path = path.CGPath;
    
    CAShapeLayer *layer = (CAShapeLayer *)[self.carvedLayer sublayers].firstObject;
    layer.path = [pLine bezierPathByReversingPath].CGPath;
    
}

#pragma mark - UIScrollViewDelegate methods
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imgView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    
}

#pragma mark - Actions 
- (void)onCancelEditAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onConfirmEditAction:(id)sender
{
    UIImagePickerController *imgPicker = (UIImagePickerController *)self.navigationController;
    if ([imgPicker.delegate respondsToSelector:@selector(imagePickerController:didFinishPickingMediaWithInfo:)]) {
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        info[UIImagePickerControllerOriginalImage] = self.image;
        info[UIImagePickerControllerEditedImage] = [self cropedImage];
        [imgPicker.delegate imagePickerController:imgPicker didFinishPickingMediaWithInfo:info];
    }
}

- (UIImage *)cropedImage
{
    if (!self.image) {
        return [UIImage new];
    }
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(keyWindow.frame.size, YES, scale);
    [keyWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = width / _whRatio;
    CGFloat y = (self.view.bounds.size.height - 44 - height) / 2.;
    
    CGRect rect = CGRectMake(0, y * scale, width * scale, height * scale);
    
    UIImage *croped = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(image.CGImage, rect)];
    
    return croped;
}

#pragma mark - getter & setter methods

- (UIScrollView *)ctntView
{
    if (!_ctntView) {
        CGRect frame = self.view.bounds;
        frame.size.height -= 44.f;
        _ctntView = [[UIScrollView alloc] initWithFrame:frame];
        _ctntView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _ctntView.delegate = self;
        _ctntView.maximumZoomScale = 3;
        _ctntView.alwaysBounceVertical = YES;
        _ctntView.alwaysBounceHorizontal = YES;
        _ctntView.showsVerticalScrollIndicator = NO;
        _ctntView.showsHorizontalScrollIndicator = NO;
        [self.view addSubview:_ctntView];
    }
    return _ctntView;
}

- (UIImageView *)imgView
{
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self.ctntView addSubview:_imgView];
    }
    return _imgView;
}

- (CAShapeLayer *)carvedLayer
{
    if (!_carvedLayer) {
        _carvedLayer = [CAShapeLayer layer];
        CGRect frame = self.view.bounds;
        frame.size.height -= 44.f;
        _carvedLayer.frame = frame;
        _carvedLayer.fillColor = [[UIColor blackColor] colorWithAlphaComponent:0.3].CGColor;
        
        CAShapeLayer *curveLayer = [CAShapeLayer layer];
        curveLayer.strokeColor = [UIColor whiteColor].CGColor;
        curveLayer.fillColor = [UIColor clearColor].CGColor;
        curveLayer.lineWidth = 1.0;
        [_carvedLayer addSublayer:curveLayer];
        
        [self.view.layer addSublayer:_carvedLayer];
    }
    return _carvedLayer;
}

- (void)setWhRatio:(CGFloat)whRatio
{
    _whRatio = whRatio;
    
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = width / _whRatio;
    CGFloat y = (self.view.bounds.size.height - 44 - height) / 2.;
    
    CGRect rect = CGRectMake(0, y, width, height);
    
    [self showCarvedWithRect:rect];
}

@end
