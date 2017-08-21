//
//  SurroundingFlowLayout.h
//  MineTrip
//
//  Created by ChangWingchit on 2017/6/24.
//  Copyright © 2017年 chit. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SurroundingFlowLayoutDelegate <NSObject>

@required
/**
 *  设置每个item的自身高度
 *  @param indexPath 所在的位置
 *  @return 高度
 */
- (CGFloat)itemHeightLayOut:(NSIndexPath *)indexPath;

@end

@interface SurroundingFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, assign)NSInteger colNum;//列数
@property (nonatomic, assign)CGFloat interSpace;//每个item的间隔
@property (nonatomic, assign)UIEdgeInsets edgeInsets;//整个CollectionView的间隔
@property (nonatomic, weak) id<SurroundingFlowLayoutDelegate> delegate;

@end
