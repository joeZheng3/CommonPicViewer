//
//  SurroundingFlowLayout.m
//  MineTrip
//
//  Created by ChangWingchit on 2017/6/24.
//  Copyright © 2017年 chit. All rights reserved.
//

#import "SurroundingFlowLayout.h"

@implementation SurroundingFlowLayout
{
    NSMutableArray *_columHeightArray;
    NSMutableArray *_attributeArray;
}

- (void)setColNum:(NSInteger)colNum {
    if (_colNum != colNum) {
        _colNum = colNum;
        [self invalidateLayout];//重新布局
    }
}

- (void)setInterSpace:(CGFloat)interSpace {
    if (_interSpace != interSpace) {
        _interSpace = interSpace;
        [self invalidateLayout];//重新布局
    }
}

- (void)setEdgeInsets:(UIEdgeInsets)edgeInsets {
    if (!UIEdgeInsetsEqualToEdgeInsets(_edgeInsets, edgeInsets)) {
        _edgeInsets = edgeInsets;
        [self invalidateLayout];//重新布局
    }
}

//作用:计算cell的布局,条件:cell的位置是固定不变
- (void)prepareLayout {
    [super prepareLayout];
    _columHeightArray = [NSMutableArray arrayWithCapacity:_colNum];
    _attributeArray = [NSMutableArray array];
    for (int index = 0; index < _colNum; index++) {
        _columHeightArray[index] = @(_edgeInsets.top);
    }
    
    //总宽度
    CGFloat totalWidth = self.collectionView.bounds.size.width;
    //每行所有的item的总宽度
    CGFloat totalItemWidth = totalWidth - _edgeInsets.left - _edgeInsets.right - _interSpace*(_colNum-1);
    //每个item的平均宽度
    CGFloat itemwidth = totalItemWidth/_colNum;
    //当前分区所有item的总个数
    NSInteger totalItems = [self.collectionView numberOfItemsInSection:0];
    for (int i = 0; i < totalItems; i++) {
        NSInteger currentCol = [self minCurrentCol];//获取最小列索引
        
        CGFloat xPos = _edgeInsets.left+(itemwidth+_interSpace)*currentCol;
        CGFloat yPos = [_columHeightArray[currentCol] floatValue];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        CGFloat itemHeight = 0.0;
        if (_delegate && [_delegate respondsToSelector:@selector(itemHeightLayOut:)]) {
            itemHeight = [_delegate itemHeightLayOut:indexPath];
        }
        CGRect frame = CGRectMake(xPos, yPos, itemwidth, itemHeight);
        UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attribute.frame = frame;
        [_attributeArray addObject:attribute];
        CGFloat upDateY = [_columHeightArray[currentCol] floatValue] + itemHeight + _interSpace;
        _columHeightArray[currentCol] = @(upDateY);
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *resultArray = [NSMutableArray array];
    for (UICollectionViewLayoutAttributes *attributes in _attributeArray) {
        CGRect rect1 = attributes.frame;
        if (CGRectIntersectsRect(rect1, rect)) {
            [resultArray addObject:attributes];
        }
    }
    return resultArray;
}

// 计算collectionView滚动范围
- (CGSize)collectionViewContentSize {
    CGFloat width = self.collectionView.frame.size.width;
    NSInteger index = [self maxCuttentCol];
    CGFloat height = [_columHeightArray[index] floatValue];
    return CGSizeMake(width, height);
}

//每次取最小y的列索引
- (NSInteger)minCurrentCol {
    __block CGFloat minHeight = MAXFLOAT;
    __block NSInteger minCol = 0;
    [_columHeightArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat heightInArray = [_columHeightArray[idx] floatValue];
        if (heightInArray < minHeight ) {
            minHeight = heightInArray;
            minCol = idx;
        }
    }];
    return minCol;
}

//每次取最大y的列索引
- (NSInteger)maxCuttentCol {
    __block CGFloat maxHeight = 0.0;
    __block NSInteger maxIndex = 0;
    [_columHeightArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat heightInArray = [_columHeightArray[idx] floatValue];
        if (heightInArray > maxHeight ) {
            maxHeight = heightInArray;
            maxIndex = idx;
        }
    }];
    return maxIndex;
}

@end
