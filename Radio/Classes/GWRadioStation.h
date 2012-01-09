//
//  GWRadioStation.h
//  Radio
//
//  Created by Øystein Riiser Gundersen on 17.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GWOrderedDictionary.h"

@interface GWRadioStation : NSObject {
    NSString *_name;
    NSURL *_streamURL;
    NSURL *_metadataURL;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSURL *streamURL;
@property (nonatomic, copy) NSURL *metadataURL;

+ (GWOrderedDictionary *)loadRadioStations;

@end
