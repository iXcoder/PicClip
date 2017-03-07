//
//  ViewController.m
//  PicClip
//
//  Created by iXcoder on 2017/3/7.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "ViewController.h"
#import "RXPicClipViewController.h"

@interface ViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    
}

@property (nonatomic, strong) UIImageView *imgView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)loadView
{
    [super loadView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(0, self.view.bounds.size.height - 40, self.view.bounds.size.width, 40);
    [button setTitle:@"选择图片" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showImgSrc:) forControlEvents:UIControlEventTouchUpInside];
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:button];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - self defined methods
- (void)showImgSrc:(id)sender
{
    UIAlertController *actSht = [UIAlertController alertControllerWithTitle:@"选择图片来源" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    [actSht addAction:[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showImgPicker:UIImagePickerControllerSourceTypePhotoLibrary];
    }]];
    if (TARGET_OS_IOS && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [actSht addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self showImgPicker:UIImagePickerControllerSourceTypeCamera];
        }]];
    }
    [actSht addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:actSht animated:YES completion:nil];
}

- (void)showImgPicker:(UIImagePickerControllerSourceType)src
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = src;
    picker.delegate = self;
    picker.allowsEditing = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = nil;
    if (![info.allKeys containsObject:UIImagePickerControllerEditedImage]) {
        RXPicClipViewController *picClip = [RXPicClipViewController new];
        picClip.image = info[UIImagePickerControllerOriginalImage];
        picClip.whRatio = self.imgView.frame.size.width / self.imgView.frame.size.height;
        [picker pushViewController:picClip animated:true];
        return ;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        self.imgView.image = image;
    }];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - getter & setter methods
- (UIImageView *)imgView
{
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 375)];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        [self.view addSubview:_imgView];
    }
    return _imgView;
}

@end
