//
//  iturtleAppDelegate.h
//  iturtle
//
//  Created by John McLaughlin on 4/6/10.
//  Copyright Loghound.com 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TurtleViewController.h"

@interface iturtleAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	IBOutlet TurtleViewController *turtleViewController;

}

@property (retain) 	IBOutlet TurtleViewController *turtleViewController;;

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

