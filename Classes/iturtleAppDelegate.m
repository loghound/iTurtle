//
//  iturtleAppDelegate.m
//  iturtle
//
//  Created by John McLaughlin on 4/6/10.
//  Copyright Loghound.com 2010. All rights reserved.
//

#import "iturtleAppDelegate.h"

@implementation iturtleAppDelegate

@synthesize window,parser,outputView;
@synthesize debugView,inputView;
@synthesize frequency;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
    // Override point for customization after application launch
	
    [window makeKeyAndVisible];
	NSString *defaultText=[[NSBundle mainBundle]pathForResource:@"defaultTurtle" ofType:@"txt"];
	if (defaultText) {
		self.inputView.text=[NSString stringWithContentsOfFile:defaultText];
	} else
		self.inputView.text=@"";
	self.frequency=9e-7;
	

    return YES;
}


-(IBAction) doIt:(id) sender {
	self.parser=[[LogoParser alloc]initWithOutputView:outputView errorView:debugView]; // nil error view
	
    [self.parser setListing:self.inputView.text];
	 [self.parser doCommand];
		 [self.parser doCommand];
		 [self.parser doCommand];
	
	[self.outputView setNeedsDisplay];
	
}
//***********************************************************/
// timerStop - Stops the timer
//
- (void)timerStop
{
	if(timer)
	{
		[timer invalidate];
		[timer release];
		timer = NULL;
	}
}


//***********************************************************/
// timerStart - Starts the timer
//
- (void)timerStart
{
	// First stop the timer if it has already been started, so we can start over from scratch
	if(timer)
	{
		[self timerStop];
	}
	
	// Now create the timer.
	timer = [NSTimer scheduledTimerWithTimeInterval:frequency target:self selector:@selector(timerTask:) userInfo:NULL repeats:YES];
	[timer retain];
}


//***********************************************************/
// timerTask - Details what to do each timer interval
//
- (void)timerTask:(NSTimer *)aTimer
{
	long		stat;
	long		count;
	BOOL		refresh;
	
	count = 6;					// we're cheating here. :)
	refresh = NO;				// per default, don't refresh!
	while(count--)
	{
		stat = [parser doCommand];
		if(kParserUpdateDisplay == stat)
		{
			refresh = YES;
		}
		else if(kParserStop == stat)
		{
			refresh = YES;
			[self timerStop];
			break;
		}
	}
	
	if(refresh)
	{
		[outputView setNeedsDisplay];
	}
	
#if 0
	switch([parser doCommand])
	{
		case kParserStop:			// stop interpreting the program
			[self timerStop];
			// FallThru...
		case kParserUpdateDisplay:		// not all commands update the display; eg. pen up or if the pen is up and the turtle is moving...
			[outputView setNeedsDisplay:YES];
			// FallThru...
		case kParserContinue:			// don't need to do anything
			break;
	}
#endif
}

//***********************************************************/
// run - Starts the timer, and hence the turtle's drawing
//
- (void)run
{
	[self timerStop];				// stop processing commands, so that variables are not changed after re-initializing them
#if (defined(DEBUGFLAG) && DEBUGFLAG)
	//	DUMP_OBCOUNT();
#endif
	[parser reset];					// re-initialize variables
	[parser setListing:self.inputView.text];
	[self timerStart];				// start processing
}


//***********************************************************/
// stop - Stops the timer, and hence the turtle's drawing
//
- (void)stop
{
	[self timerStop];	// stop processing commands
#if (defined(DEBUGFLAG) && DEBUGFLAG)
	//	[parser forgetAll];	// clear memory used by parser (for debugging only, as the user should be able to print the output, AND if we need to redraw, we won't have the drawing commands, if we use forgetAll!)
	//	DUMP_OBCOUNT();
#endif
}


// Action method
- (IBAction)run:(id)sender
{
	[self run];
}

// Action method
- (IBAction)stop:(id)sender
{
	[self stop];
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
