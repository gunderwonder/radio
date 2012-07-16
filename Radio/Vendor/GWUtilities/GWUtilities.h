//
//  GWUtilities.h
//  Radio
//
//  Created by Øystein Riiser Gundersen on 08.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef Radio_GWUtilities_h
#define Radio_GWUtilities_h

#import "GWOrderedDictionary.h"

#define UIColorRGB(r, g, b)         ([UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1])
#define UIColorRGBA(r, g, b, a)     ([UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a])
#define UIColorHex(rgbValue)        ([UIColor \
                                        colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
                                        green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
                                        blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0])

#define GWDegreesToRadians(angle)   ((angle) / 180.0 * M_PI)

// https://gist.github.com/992787
#define CGRectWithPosition(r, x, y)     CGRectMake(x, y, r.size.width, r.size.height)
#define CGRectWithX(r, x)               CGRectMake(x, r.origin.y, r.size.width, r.size.height)
#define CGRectWithY(r, y)               CGRectMake(r.origin.x, y, r.size.width, r.size.height)
#define CGRectWithSize(r, w, h)         CGRectMake(r.origin.x, r.origin.y, w, h)
#define CGRectWithWidth(r, w)           CGRectMake(r.origin.x, r.origin.y, w, r.size.height)
#define CGRectWithHeight(r, h)          CGRectMake(r.origin.x, r.origin.y, r.size.width, h)

// http://stackoverflow.com/questions/969130/nslog-tips-and-tricks
#ifdef DEBUG
#   define GWDebug(fmt, ...) NSLog((@"%s:%d " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define GWDebug(...)
#endif

// ALog always displays output regardless of the DEBUG setting
#define GWLog(fmt, ...) NSLog((@"%s:%d " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);


#endif
