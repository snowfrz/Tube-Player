//
//  RLXStoreTableViewCell.m
//  Relax
//
//  Created by Justin Proulx on 2018-04-21.
//  Copyright © 2018 Low Budget Animation Studios. All rights reserved.
//

#import "RLXStoreTableViewCell.h"

@implementation RLXStoreTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)layoutSubviews
{
    [self doCircleRadius];
}

- (void)doCircleRadius
{
    self.layer.cornerRadius = MIN(self.bounds.size.width, self.bounds.size.height) / 4;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
