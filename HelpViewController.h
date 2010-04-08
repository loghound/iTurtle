//
//  HelpViewController.h
//  iturtle
//
//  Created by John McLaughlin on 4/7/10.
//  Copyright 2010 Loghound.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HelpViewController : UIViewController {
	IBOutlet UIWebView *webView;
}

@property (retain) UIWebView *webView;

@end
