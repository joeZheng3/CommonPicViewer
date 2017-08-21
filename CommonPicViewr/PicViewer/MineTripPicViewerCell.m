//
//  MineTripPicViewerCell.m
//  MineTrip
//
//  Created by ChangWingchit on 2017/6/26.
//  Copyright © 2017年 chit. All rights reserved.
//

#import "MineTripPicViewerCell.h"

@implementation MineTripPicViewerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.picImageView.layer.cornerRadius = 10.0;
    self.picImageView.layer.masksToBounds = YES;
}

@end
