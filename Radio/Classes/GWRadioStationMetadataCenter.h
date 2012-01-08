//
//  GWRadioStationMetadataCenter.h
//  Radio
//
//  Created by Øystein Riiser Gundersen on 17.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GWRadioStation.h"

#define GWRadioStationMetadataDidChangeNotification @"GWRadioStationMetadataDidChangeNotification"

@interface GWRadioStationMetadataCenter : NSObject {
    NSURL *_metadataURL;
    NSTimer *_pollTimer;
    GWRadioStation *_currentStation;
    NSDictionary *_currentMetadata;
}

@property (nonatomic, copy) NSURL *metadataURL;

+ (GWRadioStationMetadataCenter *)sharedCenter;

- (void)startGatheringMetadataForStation:(GWRadioStation *)station;
- (void)stopGatheringMetadata:(GWRadioStation *)station;



@end
