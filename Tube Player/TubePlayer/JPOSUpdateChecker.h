//
//  JPOSUpdateChecker.h
//  Tube Player
//
//  Created by Justin Proulx on 2018-06-02.
//  Copyright © 2018 Low Budget Animation Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JPOSUpdateChecker : NSObject

- (void)checkForUpdatesAtURL:(NSString *)appInfoPlistURL withAppName:(NSString *)appName andAppHost:(NSString *)appHost andHostURL:(NSString *)hostURL;

@end
