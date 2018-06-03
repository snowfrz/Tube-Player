//
//  RLXSearchTableViewCell.h
//  Relax
//
//  Created by Justin Proulx on 2018-03-10.
//  Copyright © 2018 Low Budget Animation Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CircleProgressBar/CircleProgressBar.h>

@interface RLXSearchTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIButton *downloadButton;
@property (nonatomic, weak) IBOutlet UIButton *shareButton;
@property (nonatomic, strong) IBOutlet UIImageView *thumbnailImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *channelLabel;
@property (nonatomic, weak) IBOutlet UILabel *priceLabel;
@property (nonatomic, weak) IBOutlet CircleProgressBar *progressBar;
@property (nonatomic, weak) IBOutlet UIImageView *downloadComplete;


@end
