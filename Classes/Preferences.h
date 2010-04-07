//
//  Preferences.h
//  xlogo
//
//  Created by Jens Bauer on Thu Jul 31 2003.
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

#import <UIKit/UIKit.h>


@interface Preferences : NSObject
{
	IBOutlet id		window;

	unsigned long	maxTurtles;
	float			lineWidth;
	float			turtleSpeed;
	BOOL			saveTurtleSpeed;

	NSUserDefaults	*defaults;
}
+ (Preferences *)sharedInstance;

- (id)init;
- (void)dealloc;
- (IBAction)apply:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)ok:(id)sender;
- (IBAction)openPanel:(id)sender;
- (IBAction)revert:(id)sender;
- (IBAction)revertToFactorySettings:(id)sender;
- (IBAction)save:(id)sender;

+ (void)openPanel;
+ (void)readFromDisk;
+ (void)writeToDisk;

- (void)readPreferencesFromDisk;
- (void)writePreferencesToDisk;

// Accessors (you need to access indirectly through [[Preferences sharedInstance] maxTurtles]; !)
- (void)setMaxTurtles:(unsigned long)aMaxTurtles;
- (unsigned long)maxTurtles;
- (void)setTurtleSpeed:(float)aFrequency;
- (float)turtleSpeed;
- (void)setSaveTurtleSpeed:(BOOL)aSaveSpeed;
- (BOOL)saveTurtleSpeed;
- (void)setLineWidth:(float)aLineWidth;
- (float)lineWidth;
@end
