//
//  TurtleView.m
//  Software: XLogo
//
//  Created by Jens Bauer & Jeff Skrysak on Thu Jun 26 2003.
//
//  Copyright (c) 2003 Jens Bauer & Jeff Skrysak
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions
//  are met:
//  1. Redistributions of source code must retain the above copyright
//     notice, this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright
//     notice, this list of conditions and the following disclaimer in the
//     documentation and/or other materials provided with the distribution.
//
//   THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
//   ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//   ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
//   FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//   DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
//   OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
//   HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
//   LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
//   OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
//   SUCH DAMAGE.
//

#if (defined(DEBUGFLAG) && DEBUGFLAG)
//#define TIME_IT
#endif

#import "TurtleView.h"
#import "DrawCommand.h"
#import "Turtle.h"
#import "LogoParser.h"
#import "LogoColorTable.h"
#import "Preferences.h"

#ifdef TIME_IT
#include "Utilities.h"
#endif

@implementation TurtleView

@synthesize parser;

- (id)init	// never invoked (!)
{
	self = [super init];
	if(self)
	{
		path = NULL;
		drawCommands = NULL;
		paperColor = 0;
	}
	return(self);
}

- (void)dealloc
{
	[path release];
	[self clear];
	[super dealloc];
}

- (void)setup
{
	initializeFlag = YES;
	[self setPaperColor:[LogoColorTable indexByName:@"white"]];
}


// Added by Jeff Skrysak
- (BOOL)isOpaque
{
	// According to Apple (the DotView example), this is good for NSViews that
	// fill themselves totally, and re-draw themselves totally. It is supposed to
	// help performance. Check the NSView documentation to verify.
	return YES;
}

//************************************************************/
// drawRect - The standard NSView method to handle drawing
//
- (void)drawRect:(CGRect)rect
{
	CGRect bounds=[self bounds];
	CGContextRef context=UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, 0, bounds.size.height);
	CGContextScaleCTM(context, 1, -1);
#ifdef TIME_IT
	static int		initTime = 1;
	static double	startTime1;
	static double	startTime2;
	register double	time1;
	register double	time2;
	register double	time;
#endif

	DrawCommand	*drawCommand;
	unsigned	i;
	unsigned	count;
	CGPoint		pt;
	NSArray		*turtles;
	float		hOffset;
	float		vOffset;
	UIColor		*theColor;
	float		lineWidth;

#ifdef TIME_IT
	if(initTime)
	{
		initTime = 0;
		startTime1 = FSTime();
		startTime2 = FSTime();
	}
	else
	{
		time = FSTime();
		time1 = time - startTime1;
//		DEBUGMSG("time spent outside drawRect:%g seconds\n", time1);
		startTime2 = time;
	}
#endif
	// If the view hasn't been setup, do that now
	if(!initializeFlag)
	{
		[self setup];
	}
#if (defined(DEBUGFLAG) && DEBUGFLAG)
//#define DISABLE_DRAWING
#endif

#ifndef DISABLE_DRAWING
	theColor = [LogoColorTable color:[self paperColor]];

	if(!path)
	{
		path = [[[UIBezierPath alloc] init] retain];
		[path setLineCapStyle:   kCGLineCapRound];
		[path setLineJoinStyle:  kCGLineJoinRound];
		[path setMiterLimit:4.0];
	}

	// Draw the background (white)
	[theColor set];		// this does cost something. (2% cpu-time)
	UIRectFill(rect);	// This does cost a whole lot.

	// Find home (0, 0)
	hOffset = [self frame].size.width / 2;
	vOffset = [self frame].size.height / 2;

	// Fix for antialiasing:
	hOffset = (float) ((int) hOffset) + .5;
	vOffset = (float) ((int) vOffset) + .5;

	// Start off at (0, 0)
	pt.x = hOffset;
	pt.y = vOffset;

	// Get the path's line width again, in case it has changed
	lineWidth = [[Preferences sharedInstance] lineWidth];

	// Go through all of the paths and draw them
	count = [drawCommands count];

	[path setLineWidth:lineWidth];
//		[path setLineWidth:[[Preferences sharedInstance] lineWidth]];	// implement this
	for(i = 0; i < count; i++)
	{
		drawCommand = [drawCommands objectAtIndex:i];
		if([drawCommand color] != theColor)	// only set the color if it has changed (this is a try of optimizing the app)
		{
			theColor = [drawCommand color];
			[theColor set];
		}
		if([drawCommand lineWidth] != lineWidth)
		{
			lineWidth = [drawCommand lineWidth];
			[path setLineWidth:lineWidth];
		}

		// Drawing one line at a time is faster than drawing multiple lines. This is due to that Quartz would have to do much more rendering on line-ends if we're drawing more than one line at a time. (eg. line-ends 'bends', instead of 'breaks')
		pt = [drawCommand fromPoint];
		pt.x += hOffset;
		pt.y += vOffset;
		[path moveToPoint:pt];
		pt = [drawCommand toPoint];
		pt.x += hOffset;
		pt.y += vOffset;
		[path addLineToPoint:pt];
		[path stroke];
		[path removeAllPoints];		// removing all points is faster than deallocating and reallocating. <JB>
	}

	pt.x = hOffset;
	pt.y = vOffset;
	turtles = [parser turtles];		// Get the list of turtles
	count = [turtles count];		// Find the number of turtles

	// Now draw edach turtle
	for(i = 0; i < count; i++)
	{
		[[turtles objectAtIndex:i] drawAtOffset:pt];
	}
	// Draw a border (default: black, 1 pixel wide) around the view [Added by Jeff Skrysak]
	//[[UIColor blackColor] set];
	//UIRectFrame(rect);
#endif
#ifdef TIME_IT
	time = FSTime();
	time2 = time - startTime2;
//	DEBUGMSG("time inside drawRect:%g seconds\n", time2);
	DEBUGMSG("inside:%g%%, outside:%g%%\n", time2 * 100.0 / (time1 + time2), time1 * 100.0 / (time1 + time2));
	startTime1 = time;
#endif
}

//************************************************************/
// addCommand - Add a new drawing command to the array
//
- (void)addCommand:(DrawCommand *)drawCommand
{
	// Okay, if the view hasn't initialized yet, get that done
	if(!initializeFlag)
	{
		[self setup];
	}

	// Also, if the array of commands hasn't been initialized yet, do that
	// otherwise we could get some nasty effects
	if(!drawCommands)
	{
		drawCommands = [[NSMutableArray array] retain];
	}

	// NOW we add the new command..
	[drawCommands addObject:drawCommand];
}

- (BOOL)clear
{
	if(!initializeFlag)
	{
		[self setup];
	}

	if(drawCommands)
	{
		[drawCommands removeAllObjects];	// it seems this is not done on release!
		[drawCommands release];
		drawCommands = NULL;
		return(YES);
	}
	return(NO);
}

- (BOOL)setPaperColor:(float)aPaperColor
{
	if(paperColor != aPaperColor)
	{
		paperColor = aPaperColor;
		return(YES);
	}
	return(NO);
}

// Accessor method
- (float)paperColor
{
	return(paperColor);
}

@end
