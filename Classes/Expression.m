//
//  Expression.m
//  Software: XLogo
//
//  Created by Jens Bauer on Thu Jun 26 2003.
//
//  Copyright (c) 2003 Jens Bauer
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

#import "Expression.h"
#include "Utilities.h"

@implementation Expression

- (id)init
{
	self = [super init];
	if(self)
	{
		type = 0;
#if (defined(DEBUGFLAG) && DEBUGFLAG)
	INC_OBCOUNT("Expression");
#endif
	}
	return(self);
}

- (void)dealloc
{
	[self reset];
#if (defined(DEBUGFLAG) && DEBUGFLAG)
	DEC_OBCOUNT("Expression");
#endif
	[super dealloc];
}

- (void)reset
{
	if((kExpressionKindNumber & type) && ptr)	// Hum, I dislike my own code. Better rewrite this thing some day.
	{
		free(ptr);
	}
	type = 0;
	ptr = NULL;
}

- (unichar *)allocBufferOfSize:(unsigned long)size
{
	return((unichar *)malloc(sizeof(unichar) * size));
}

- (void)setFloatValue:(double)aFloat
{
	[self reset];
	type = kExpressionKindFloatValue;
	number = aFloat;
}

- (double)floatValue
{
	if(kExpressionKindNumber & type)
	{
		return(number);
	}
	return(0.0);
}

- (void)setStringValue:(const unichar *)aString ofLength:(unsigned long)aLength
{
	[self reset];
	type = kExpressionKindStringValue;
	ptr = (void *) aString;
	length = aLength;
}

- (unichar *)stringValue
{
	char	temp[256];

	if(kExpressionKindStringValue == type)
	{
		return(ptr);
	}
	else if(kExpressionKindNumber & type)	// Hum, I dislike my own code. Better rewrite this thing some day.
	{
		if(NULL == ptr)		// lazy initializing of a string, only initialized when used, this speeds up our processing. :)
		{
			snprintf(temp, 255, "%g", number);
			temp[255] = '\0';
			length = strlen(temp);
			ptr = strdup2unistr(temp);
		}
		return(ptr);
	}
	return(NULL);
}

- (void)setListValue:(const unichar *)aList ofLength:(unsigned long)aLength
{
	[self reset];
	type = kExpressionKindListValue;
	ptr = (void *) aList;
	length = aLength;
}

- (unichar *)listValue
{
	if(kExpressionKindListValue == type)
	{
		return(ptr);
	}
	return(NULL);
}

- (unsigned long)length
{
	if(kExpressionKindPointer & type)
	{
		return(length);
	}
	else if(kExpressionKindNumber & type)
	{
		if(NULL == ptr)
		{
			(void) [self stringValue];
		}
		return(length);
	}
	return(0);
}

- (long)type
{
	return(type);
}

@end
