//
//  GWRadioTuner.h
//  Radio
//
//  Created by Øystein Riiser Gundersen on 17.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AudioStreamer.h"
#import "GWRadioStation.h"

@interface GWRadioTuner : NSObject {
    AudioStreamer *_streamer;
    NSDictionary *_radioStations;
    GWRadioStation *_currentStation;
}

@property (nonatomic, retain) NSDictionary *radioStations;
@property (nonatomic, retain) GWRadioStation *currentStation;

- (id)initWithStations:(NSDictionary *)stations;
- (GWRadioStation *)currentStation;

- (void)tuneInStationWithName:(NSString *)name;
- (void)pause;
- (void)stop;
- (void)start;

- (BOOL)isPlaying;



@end
