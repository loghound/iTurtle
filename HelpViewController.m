    //
//  HelpViewController.m
//  iturtle
//
//  Created by John McLaughlin on 4/7/10.
//  Copyright 2010 Loghound.com. All rights reserved.
//

#import "HelpViewController.h"


@implementation HelpViewController
@synthesize webView;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	NSString *helpString=[[NSBundle mainBundle]pathForResource:@"docs" ofType:@"html"];
	
	[self.webView loadHTMLString:[NSString stringWithContentsOfFile:helpString] baseURL:nil];
    [super viewDidLoad];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
	self.webView=nil;
	NSLog(@"unloaded view");
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	NSLog(@"help view dealloc");
    [super dealloc];
}


@end
