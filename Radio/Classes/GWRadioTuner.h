//
//  GWRadioTuner.h
//  Radio
//
//  Created by Øystein Riiser Gundersen on 17.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "GWRadioStation.h"
#import "AudioStreamer.h"

@interface GWRadioTuner : NSObject {

    NSDictionary *_radioStations;
    GWRadioStation *_currentStation;
    AVPlayer *_player;
    AudioStreamer *_streamer;
}

#pragma mark - Accessors
@property (nonatomic, retain) NSDictionary *radioStations;
@property (nonatomic, retain) GWRadioStation *currentStation;

#pragma mark - Initializers
- (id)initWithStations:(NSDictionary *)stations;

#pragma mark - Station selection
- (void)tuneInStationWithName:(NSString *)name;
- (void)tuneInStationWithIndex:(NSUInteger)index;
- (GWRadioStation *)currentStation;

#pragma mark - Playback
- (void)pause;
- (void)play;
- (BOOL)isPlaying;


@end
