//
//  Preferences.m
//  xlogo
//
//  Created by Jens Bauer on Thu Jul 31 2003.
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

#import "Preferences.h"

// See the BrainStorm sheet for preference-suggestions!


@implementation Preferences

static Preferences	*sharedInstance = NULL;

+ (Preferences *)sharedInstance
{
	return(sharedInstance ? sharedInstance : [[self alloc] init]);
}

- (id)init
{
	if(sharedInstance)
	{
		[self release];
	}
	else
	{
		self = [super init];
		if(self)
		{
			sharedInstance = self;
			[self readPreferencesFromDisk];
		}
	}
	return(sharedInstance);
}

- (void)dealloc
{
	if(self != sharedInstance)
	{
		[super dealloc];							// Don't free the shared instance
	}
}

+ (void)readFromDisk
{
	[Preferences sharedInstance];					// This is enough!
}

+ (void)writeToDisk
{
	[[Preferences sharedInstance] writePreferencesToDisk];
}

+ (void)openPanel
{
	[[Preferences sharedInstance] openPanel:self];
}

- (IBAction)apply:(id)sender
{
}

- (IBAction)cancel:(id)sender
{
}

- (IBAction)dummy:(id)sender	// This is just a temporary method. It's called each time the user changes a value in the preference panel
{
}

- (IBAction)ok:(id)sender
{
}

- (IBAction)openPanel:(id)sender
{
	[window makeKeyAndOrderFront:NULL];
}

- (IBAction)revert:(id)sender
{
}

- (IBAction)revertToFactorySettings:(id)sender
{
}

- (IBAction)save:(id)sender
{
}

- (void)readPreferencesFromDisk
{
	id		value;

	// Setup default-values ("fallback")
	maxTurtles = 100;
	saveTurtleSpeed = YES;
	turtleSpeed = 1.0;			// full speed! 2.0 = double speed, 0.5 = half speed
	lineWidth = 3.0;

	// Now try reading the preferences:
	defaults = [NSUserDefaults standardUserDefaults];

	// Get max turtles, if present:
	value = [defaults objectForKey:@"Maximum Turtles"];
	if(value)
	{
		maxTurtles = [value intValue];
	}

	// Get turtle speed, if present:
	value = [defaults objectForKey:@"Turtle Speed Boolean"];
	if(value)
	{
		saveTurtleSpeed = [value boolValue];
	}
	value = [defaults objectForKey:@"Turtle Speed"];
	if(value)
	{
		turtleSpeed = [value floatValue];
	}

	// Get line width, if present:
	value = [defaults objectForKey:@"Line Width"];
	if(value)
	{
		lineWidth = [value floatValue];
	}
}

- (void)writeMaxTurtles
{
	// Store the value for the maximum number of turtles
	[defaults setInteger:maxTurtles forKey:@"Maximum Turtles"];
}

- (void)writeSaveTurtleSpeed
{
	// Store the value of the turtle speed boolean
	[defaults setBool:saveTurtleSpeed forKey:@"Turtle Speed Boolean"];
}

- (void)writeTurtleSpeed
{
	// Store the turtle speed itself
	[defaults setFloat:turtleSpeed forKey:@"Turtle Speed"];
}

- (void)writeLineWidth
{
	// Store the value of the line width
	[defaults setFloat:lineWidth forKey:@"Line Width"];
}

- (void)writePreferencesToDisk
{
	[self writeMaxTurtles];
	[self writeSaveTurtleSpeed];
	[self writeTurtleSpeed];
	[self writeLineWidth];
}

- (void)setMaxTurtles:(unsigned long)aMaxTurtles
{
	maxTurtles = aMaxTurtles;
}

- (unsigned long)maxTurtles
{
	return(maxTurtles);
}

- (void)setSaveTurtleSpeed:(BOOL)aSaveSpeed
{
	saveTurtleSpeed = aSaveSpeed;
}

- (BOOL)saveTurtleSpeed
{
	return(saveTurtleSpeed);
}

- (void)setTurtleSpeed:(float)aSpeed
{
	turtleSpeed = aSpeed;
	if(saveTurtleSpeed)			// Store the speed preference (if the user so desires)
	{
		[self writeTurtleSpeed];
	}
}

- (float)turtleSpeed
{
	return(turtleSpeed);
}

- (float)lineWidth
{
	return(lineWidth);
}

- (void)setLineWidth:(float)aLineWidth
{
	lineWidth = aLineWidth;
}

@end
