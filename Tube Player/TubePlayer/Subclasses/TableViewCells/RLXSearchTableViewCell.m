//
//  RLXSearchTableViewCell.m
//  Relax
//
//  Created by Justin Proulx on 2018-03-10.
//  Copyright © 2018 Low Budget Animation Studios. All rights reserved.
//

#import "RLXSearchTableViewCell.h"

@implementation RLXSearchTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self doCircleRadius];
    
    //let the completion image get tinted
    UIImage *downloadCompletedImage = [[UIImage imageNamed:@"Checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.downloadComplete.image = downloadCompletedImage;
    self.downloadComplete.tintColor = [UIColor whiteColor];
    
    self.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    
    //hide download features
    BOOL canDownload = [[[NSUserDefaults standardUserDefaults] objectForKey:@"devdl"] boolValue];
    if (canDownload != YES)
    {
        self.downloadButton.hidden = YES;
        self.downloadComplete.hidden = YES;
        self.shareButton.hidden = YES;
    }
}

- (void)setFrame:(CGRect)frame
{
    //seperate cells
    frame.origin.y += 8;
    frame.size.height -= 2 * 8;
    
    //inset cells from edges
    frame.origin.x += 16;
    frame.size.width -=2 * 16;
    
    [super setFrame:frame];
}

- (void)doCircleRadius
{
    self.layer.cornerRadius = MIN(self.bounds.size.width, self.bounds.size.height) / 4;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
