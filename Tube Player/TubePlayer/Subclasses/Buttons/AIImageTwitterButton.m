//
//  AIImageTwitterButton.m
//  Relax
//
//  Created by Justin Proulx on 2018-03-11.
//  Copyright © 2018 Low Budget Animation Studios. All rights reserved.
//

#import "AIImageTwitterButton.h"

@implementation AIImageTwitterButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self setColours];
    [self setupShadow];
}

-(void)setColours
{
    self.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0];
}

- (void)setupShadow
{
    self.layer.shadowOpacity = 0.0f;
}

@end
