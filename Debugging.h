/*
 *  Debugging.h
 *  Software: XLogo
 *
 *  Created by Jens Bauer on Wed Jun 25 2003.
 *  Copyright (c) 2003 Jens Bauer. All rights reserved.
 *
 */

#ifndef _Debugging_h_
#define _Debugging_h_

#ifdef __cplusplus
extern "C" {
#endif

#if (defined(DEBUGFLAG) && DEBUGFLAG)
#define DEBUGMSG(a...)	fprintf(stderr, a);	fflush(stderr)
#define DEC_OBCOUNT(a)	decrement_object_count(a)
#define INC_OBCOUNT(a)	increment_object_count(a)
#define DUMP_OBCOUNT()	dump_object_count()
#else
#define DEBUGMSG(a...)
#define DEC_OBCOUNT(a)
#define INC_OBCOUNT(a)
#define DUMP_OBCOUNT()
#endif

#if (defined(DEBUGFLAG) && DEBUGFLAG)
void increment_object_count(const char *name);
void decrement_object_count(const char *name);
unsigned long get_object_count(const char *name);	/* not really used */
void dump_object_count();
#endif

#ifdef __cplusplus
}
#endif

#endif	/* _Debugging_h_ */
