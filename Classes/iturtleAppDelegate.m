//
//  iturtleAppDelegate.m
//  iturtle
//
//  Created by John McLaughlin on 4/6/10.
//  Copyright Loghound.com 2010. All rights reserved.
//

#import "iturtleAppDelegate.h"

@implementation iturtleAppDelegate


@synthesize turtleViewController,window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
    // Override point for customization after application launch
	[window addSubview:turtleViewController.view];
    [window makeKeyAndVisible];
	

	

    return YES;
}



- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
