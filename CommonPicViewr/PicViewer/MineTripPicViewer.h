//
//  MineTripPicViewer.h
//  MineTrip
//
//  Created by ChangWingchit on 2017/6/26.
//  Copyright © 2017年 chit. All rights reserved.
//

#import <UIKit/UIKit.h>
/**此图片浏览器必须要外界的图片url*/
@interface MineTripPicViewer : UIViewController
/**图片数据源*/
@property (nonatomic,strong,nullable) NSArray<NSString*> *picUrlArray;
/**选中的图片页数*/
@property (nonatomic) int page;

@end
