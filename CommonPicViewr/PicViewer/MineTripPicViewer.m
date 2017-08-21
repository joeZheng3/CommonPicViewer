//
//  MineTripPicViewer.m
//  MineTrip
//
//  Created by ChangWingchit on 2017/6/26.
//  Copyright © 2017年 chit. All rights reserved.
//

#import "MineTripPicViewer.h"
#import "MineTripPicViewerCell.h"
#import "SurroundingFlowLayout.h"
#import <YYWebImage.h>
#import "UIBarButtonItem+MineShopBarButtonCustom.h"
#import "MBProgressHUD+NJ.h"

#define IMAGETAG 1000

@interface MineTripPicViewer ()<SurroundingFlowLayoutDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate>

@property (nonatomic) BOOL isSmallPic;

@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) NSMutableArray *HA;
@property (nonatomic,strong) UILabel *titleLabel;

@end

@implementation MineTripPicViewer

#pragma mark - Lazy Load
- (UICollectionView*)collectionView
{
    return MY_LAZY(_collectionView, ({
        
        SurroundingFlowLayout *flowLayout = [[SurroundingFlowLayout alloc] init];
        flowLayout.delegate = self;
        flowLayout.interSpace = 5; //每个item的间隔
        flowLayout.edgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        flowLayout.colNum = 2; //列数
        
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;//垂直方向
        UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_WIDTH, IPHONE_HEIGHT-64) collectionViewLayout:flowLayout];
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        [collectionView registerNib:[UINib nibWithNibName:@"MineTripPicViewerCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"MineTripPicViewerCell"];
        collectionView;
    }));
}

- (UIScrollView*)scrollView
{
    return MY_LAZY(_scrollView, ({
        UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0,0, SCREEN_WIDTH,SCREEN_HEIGHT-64)];
        scrollView.bounces = YES;
        scrollView.pagingEnabled = YES;
        scrollView.delegate = self;
        
        CGFloat width = scrollView.bounds.size.width;
        
        int count = (int)self.picUrlArray.count;
        scrollView.contentSize = CGSizeMake(count*width, 0);
        scrollView.contentOffset = CGPointMake(0, 0);
        scrollView.showsHorizontalScrollIndicator = NO;
        
        if (count) {
            for (int i = 0; i<count; i++) {
                UIScrollView *subScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(i*width,0, width,scrollView.height)];
                subScrollView.delegate = self;
                subScrollView.maximumZoomScale = 2.0;
                subScrollView.minimumZoomScale = 1.0;
                [scrollView addSubview:subScrollView];
                
                UIImageView *aView = [[UIImageView alloc]initWithFrame:CGRectMake(0, scrollView.centerY-125,width,250)];
                aView.contentMode = UIViewContentModeScaleAspectFill;
                aView.userInteractionEnabled = YES;
                aView.image = [UIImage imageNamed:@"defaultimg"];
                aView.tag = IMAGETAG+i;
                [subScrollView addSubview:aView];
            }
        }
        scrollView;
    }));
}

- (NSMutableArray*)HA
{
    return MY_LAZY(_HA, ({
        NSMutableArray *arr = [NSMutableArray arrayWithArray:@[@254,@220,@190]];
        arr;
    }));
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self setupNavigationBar];
    
    [self addSubViews];
    
    [self loadData];
    
    [self handlePage];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([[[UIDevice currentDevice] systemVersion]floatValue]>=7.0) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Method
/**自定义导航栏*/
- (void)setupNavigationBar
{
    if (self.picUrlArray && [self.picUrlArray count]) {
        CGSize titleSize =self.navigationController.navigationBar.bounds.size;
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleSize.width/2, titleSize.height)];
        self.titleLabel.numberOfLines = 1;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.text = [NSString stringWithFormat:@"%d / %d",self.page,(int)self.picUrlArray.count];
        [self.navigationItem setTitleView:self.titleLabel];
    }
    
    //左边按钮
    UIBarButtonItem *leftItem = [UIBarButtonItem itemWithTarget:self action:@selector(leftBtnItemClicked:) image:@"tongyong_back-button" selectImage:nil];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -5;
    self.navigationItem.leftBarButtonItems = @[negativeSpacer, leftItem];
    
    //右边按钮
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"小图模式" style:UIBarButtonItemStylePlain target:self action:@selector(rightBtnItemClicked:)];
    UIBarButtonItem *negativeSpacer2 = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer2.width = +5;
    self.isSmallPic = YES;
    self.navigationItem.rightBarButtonItems = @[rightItem,negativeSpacer2];
}

/**导航栏左边按钮点击事件*/
- (void)leftBtnItemClicked:(UIBarButtonItem*)item
{
    [self.navigationController popViewControllerAnimated:YES];
}

/**导航栏右边按钮点击事件*/
- (void)rightBtnItemClicked:(UIBarButtonItem*)item
{
    if (self.isSmallPic) {
        [self.scrollView removeFromSuperview];
        self.scrollView = nil;
        [self.view addSubview:self.collectionView];
        item.title = @"大图模式";
        self.isSmallPic = NO;
    }else{
        [self.collectionView removeFromSuperview];
        self.collectionView = nil;
        [self.view addSubview:self.scrollView];
        [self loadData];
        item.title = @"小图模式";
        self.isSmallPic = YES;
    }
}

/**添加子视图*/
- (void)addSubViews
{
    [self.view addSubview:self.scrollView];
}

/**加载子视图图片*/
- (void)loadData
{
    if (self.picUrlArray && self.picUrlArray.count) {
        for (int i = 0; i<self.picUrlArray.count; i++) {
            NSString *imageUrl = self.picUrlArray[i];
            UIImageView *imageView = [self.scrollView viewWithTag:i+IMAGETAG];
            //给每张图片添加长按手势
            UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(isSavePhoto)];
            [imageView addGestureRecognizer:gesture];
            [imageView yy_setImageWithURL:[NSURL URLWithString:imageUrl]
                                      placeholder:[UIImage imageNamed:@"tongyong_photo"]
                                          options:YYWebImageOptionSetImageWithFadeAnimation | YYWebImageOptionShowNetworkActivity
                                       completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {}];
        }
    }
}

/**处理页数对应的位置和标题*/
- (void)handlePage
{
    NSLog(@"%d",self.page);
    [self.scrollView setContentOffset:CGPointMake((self.page-1)*SCREEN_WIDTH, 0) animated:NO];
}

/**提示窗口保存图片*/
- (void)isSavePhoto
{
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"提示" message:@"将要保存相片到您的相册中" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *save = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self savePhoto];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [vc addAction:save];
    [vc addAction:cancel];
    [self.parentViewController presentViewController:vc animated:YES completion:nil];
}

/**保存图片*/
- (void)savePhoto
{
    int currentIndex = self.scrollView.contentOffset.x/SCREEN_WIDTH;
    UIImageView *imageView = [self.scrollView viewWithTag:currentIndex+IMAGETAG];
        
    //将图片大小改小
    //    NSData *imageData = UIImageJPEGRepresentation(imageView, 0.1);
    //    UIImage *image = [UIImage imageWithData:imageData];
        
    UIImageWriteToSavedPhotosAlbum(imageView.image,self,@selector(image:didFinishSavingWithError:contextInfo:),nil);
}

/**保存照片回调方法*/
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (!error) {
        [MBProgressHUD showTestMessage:@"图片保存成功!"];
    }
    else
    {
        [MBProgressHUD showTestMessage:@"图片保存失败!"];
    }
}

#pragma mark - SurroundingFlowLayoutDelegate
- (CGFloat)itemHeightLayOut:(NSIndexPath *)indexPath
{
    while (indexPath.row >= self.HA.count) {
        [self.HA addObjectsFromArray:self.HA];
    }
    return [self.HA[indexPath.row] floatValue];//返回指定索引对应的随机高度
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.picUrlArray && [self.picUrlArray count]) {
        return [self.picUrlArray count];
    }
    return 0;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MineTripPicViewerCell *cell = (MineTripPicViewerCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"MineTripPicViewerCell" forIndexPath:indexPath];
    if (self.picUrlArray && indexPath.row < self.picUrlArray.count) {
        NSString *imageUrl = self.picUrlArray[indexPath.row];
       [cell.picImageView yy_setImageWithURL:[NSURL URLWithString:imageUrl]
                                  placeholder:[UIImage imageNamed:@"tongyong_photo"]
                                      options:YYWebImageOptionSetImageWithFadeAnimation | YYWebImageOptionShowNetworkActivity
                                   completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {}];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MineTripPicViewerCell *cell = (MineTripPicViewerCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"MineTripPicViewerCell" forIndexPath:indexPath];
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"提示" message:@"将要保存相片到您的相册中" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *save = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImageView *imageView = cell.picImageView;
        UIImageWriteToSavedPhotosAlbum(imageView.image,self,@selector(image:didFinishSavingWithError:contextInfo:),nil);
        
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [vc addAction:save];
    [vc addAction:cancel];
    [self.parentViewController presentViewController:vc animated:YES completion:nil];
}

#pragma mark - UIScrollViewDelegate
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (scrollView != self.scrollView) {
        UIView *subView = [[scrollView subviews]objectAtIndex:0]; //objectAtIndex:0是贴在scrollView上的imageView
        return subView;
    }
    return nil;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if (scrollView != self.scrollView) {
        UIImageView *tempImage = [[scrollView subviews]objectAtIndex:0];
        //居中放大缩小
        CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
        (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
        CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
        (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
        tempImage.center = CGPointMake((int)(scrollView.contentSize.width * 0.5 + offsetX),
                                       (int)(scrollView.contentSize.height * 0.5 + offsetY));
        
    }
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    self.scrollView.scrollEnabled = NO;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    self.scrollView.scrollEnabled = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.scrollView) {
        int index = scrollView.contentOffset.x/scrollView.frame.size.width;
        self.titleLabel.text = [NSString stringWithFormat:@"%d / %d",index+1,(int)self.picUrlArray.count];
    }
}


@end
