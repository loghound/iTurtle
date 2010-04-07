//
//  Expression.h
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

#include "Debugging.h"

#import <Foundation/Foundation.h>

enum
{
	kExpressionKindEmpty		= 0,

	kExpressionKindPointer		= 0x00010000,
	kExpressionKindStringValue,
	kExpressionKindListValue,

	kExpressionKindNumber		= 0x00020000,
	kExpressionKindFloatValue
};

@interface Expression : NSObject
{
	long			type;
	unsigned long	length;
	void			*ptr;
	double			number;
}
- (id)init;
- (void)dealloc;
- (void)reset;
- (void)setFloatValue:(double)aFloat;
- (double)floatValue;
- (void)setStringValue:(const unichar *)aString ofLength:(unsigned long)aLength;
- (unichar *)stringValue;
- (void)setListValue:(const unichar *)aList ofLength:(unsigned long)aLength;
- (unichar *)listValue;
- (unsigned long)length;
- (long)type;
@end
