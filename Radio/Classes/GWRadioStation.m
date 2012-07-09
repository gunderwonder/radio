//
//  GWRadioStation.m
//  Radio
//
//  Created by Øystein Riiser Gundersen on 17.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GWRadioStation.h"

@implementation GWRadioStation

@synthesize name = _name;
@synthesize streamURL = _streamURL;
@synthesize metadataURL = _metadataURL;

+ (GWOrderedDictionary *)loadRadioStations {
    NSString *stationFile = [[NSBundle mainBundle] pathForResource:@"RadioStations" ofType:@"plist"];
    NSDictionary *stationData = [[NSDictionary alloc] initWithContentsOfFile:stationFile];
    
    GWRadioStation *station = nil;
    GWOrderedDictionary *stations = [[GWOrderedDictionary alloc] init];
    for (NSString *stationName in stationData) {
        NSDictionary *data = [stationData objectForKey:stationName];
        
        station = [[GWRadioStation alloc] init];
        [station setName:stationName];
        [station setStreamURL:[NSURL URLWithString:[data objectForKey:@"streamURL"]]];
        [station setMetadataURL:[NSURL URLWithString:[data objectForKey:@"metadataURL"]]];
        
        [stations setObject:station forKey:stationName];
    }
    
    return stations;
}

@end
