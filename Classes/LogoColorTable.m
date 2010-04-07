//
//  LogoColorTable.m
//  Software: XLogo
//
//  Created by Jens Bauer on Sat Aug 02 2003.
//
//  Copyright (c) 2003 Jens B auer
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

#import "LogoColorTable.h"


@implementation LogoColorTable

static LogoColorTable	*sharedInstance = NULL;

+ (LogoColorTable *)sharedInstance
{
	return(sharedInstance ? sharedInstance : [[self alloc] init]);
}

- (void)setup
{
	unsigned long	i;
	unsigned long	j;
	unsigned long	mask;
	float			r;
	float			g;
	float			b;
	long			setupTab[10] = { 0xee, 0xdd, 0xbb, 0xaa, 0x88, 0x77, 0x55, 0x44, 0x22, 0x11 };
	unsigned long	colors;
	NSString		*name[16] = { @"black", @"blue", @"red", @"magenta", @"green", @"cyan", @"yellow", @"white", @"gray", @"bright blue", @"bright red", @"bright magenta", @"bright green", @"bright cyan", @"bright yellow", @"bright white" };

	colors = (sizeof(colorTable) / sizeof(*colorTable));
	if(colors <= 16)
	{
		for(i = 0; i < colors; i++)
		{
			colorTable[i] = [UIColor colorWithCalibratedRed:((i & 2) ? 1.0 : (i & 8) ? 0.5 : 0.0) green:((i & 4) ? 1.0 : (i & 8) ? 0.5 : 0.0) blue:((i & 1) ? 1.0 : (i & 8) ? 0.5 : 0.0) alpha:1.0];
			[colorTable[i] retain];
			nameTable[i] = name[i];
		}
	}
	else
	{
		for(i = 0; i < colors; i++)
		{
			if(i < 215)
			{
				r = 0x33 * (5 - (i % 6));
				g = 0x33 * (5 - ((i / 6) % 6));
				b = 0x33 * (5 - ((i / 36) % 6));
			}
			else
			{
				j = (i - 215);
				mask = 1 << (j / 10);					// generate a binary mask (1, 2, 4, 8 or 16)
				j %= 10;								// make j in the range 0..9
				r = (mask & 9) ? setupTab[j] : 0.0;		// if %01001 & mask
				g = (mask & 10) ? setupTab[j] : 0.0;	// if %01010 & mask
				b = (mask & 12) ? setupTab[j] : 0.0;	// if %01100 & mask
				// note: 16 only occurs once, and that's color 255, which is black, so this color will become 0x000000!
			}
			// note: When I write (1.0 / 256.0), this acts like a constant for multiplication, as division is more expensive, so it's an optimization!
			// I could have written the constant as 0.00390625, however you can't guess what that would be, just by looking at it. ;)
			colorTable[i] = [UIColor colorWithRed:(1.0 / 256.0) * r green:(1.0 / 256.0) * g blue:(1.0 / 256.0) * b alpha:1.0];
			[colorTable[i] retain];
			for(j = 0; j < 8; j++)
			{
				if(((j & 2) ? 255.0 : 0.0) == r && ((j & 4) ? 255.0 : 0.0) == g && ((j & 1) ? 255.0 : 0.0) == b)
				{
					nameTable[i] = name[j];
					break;
				}
				else if(((j & 2) ? 255.0 : 102.0) == r && ((j & 4) ? 255.0 : 102.0) == g && ((j & 1) ? 255.0 : 102.0) == b)
				{
					nameTable[i] = name[j + 8];
					break;
				}
			}
		}
	}
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
			[self setup];
			sharedInstance = self;
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

- (unsigned long)count
{
	return(sizeof(colorTable) / sizeof(*colorTable));
}

- (UIColor *)color:(unsigned long)index
{
	index %= [self count];	// I better do this, otherwise "setcolor random" won't work; "setcolor random % 255" would, though.
	if(index < (sizeof(colorTable) / sizeof(*colorTable)))
	{
		return(colorTable[index]);
	}
	return(NULL);
}

- (unsigned long)indexByName:(NSString *)aColorName
{
	unsigned long	i;

	for(i = 0; i < (sizeof(colorTable) / sizeof(*colorTable)); i++)
	{
		if([aColorName isEqualToString:nameTable[i]])
		{
			return(i);
		}
	}
	return(0xffffffff);	// not found
}

// Public Accessor method
+ (unsigned long)count
{
	return([[self sharedInstance] count]);
}

// Public Accessor method
+ (UIColor *)color:(unsigned long)index
{
	return([[self sharedInstance] color:index]);
}

// Public Accessor method
+ (unsigned long)indexByName:(NSString *)aColorName
{
	return([[self sharedInstance] indexByName:aColorName]);
}

@end
