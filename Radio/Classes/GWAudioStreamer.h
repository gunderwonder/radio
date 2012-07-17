//
//  GWAudioStreamer.h
//  Radio
//
//  Created by Øystein Riiser Gundersen on 17.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AudioStreamer.h"

@interface GWAudioStreamer : AudioStreamer

- (float)averagePowerForChannel:(NSUInteger)channelNumber;
- (NSUInteger)numberOfChannels;
- (BOOL)isMeteringEnabled;
- (void)setMeteringEnabled:(BOOL)enable;

+ (GWAudioStreamer *)streamWithURL:(NSURL*)url;

@end
