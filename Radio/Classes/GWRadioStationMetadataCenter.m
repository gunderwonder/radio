//
//  GWRadioStationMetadataCenter.m
//  Radio
//
//  Created by Øystein Riiser Gundersen on 17.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GWRadioStationMetadataCenter.h"
#import "AFNetworking.h"

static GWRadioStationMetadataCenter *sharedMetadataCenter;

@interface GWRadioStationMetadataCenter() 
@property (nonatomic, retain) NSTimer *pollTimer;

- (void)gatherMetadata;
- (void)parseMetadata:(NSDictionary *)metadata;
@end

@implementation GWRadioStationMetadataCenter

@synthesize metadataURL = _metadataURL;
@synthesize pollTimer = _pollTimer;

+ (GWRadioStationMetadataCenter *)sharedCenter {
    static BOOL initialized = NO;
    if (!initialized) {
        initialized = YES;
        sharedMetadataCenter = [[GWRadioStationMetadataCenter alloc] init];
    }
    return sharedMetadataCenter;
}

- (void)startGatheringMetadataForStation:(GWRadioStation *)station {
    [self setMetadataURL:[station metadataURL]];
    [[self pollTimer] invalidate];
    [self setPollTimer:[NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(gatherMetadata) userInfo:Nil repeats:YES]];
    [[self pollTimer] fire];
}
     
- (void)gatherMetadata {
    NSLog(@"Gathering metadata from '%@'...", [[self metadataURL] absoluteString]);
    NSURL *url = [self metadataURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self parseMetadata:JSON];
    } failure:nil];
    
    [operation start];
}

- (void)stopGatheringMetadata:(GWRadioStation *)station {
    [[self pollTimer] invalidate];
}

- (void)parseMetadata:(NSDictionary *)data {
    
    NSMutableDictionary *metadata = [[NSMutableDictionary alloc] init];
    NSLog(@"Parsing metadata %@", data);
    
    NSDictionary *program = [data objectForKey:@"program"];
    NSString *showName = [program objectForKey:@"title"];
    if (showName != nil)
        [metadata setObject:showName forKey:@"currentShowName"];
    
    NSArray *elements = [program objectForKey:@"elements"];
    if ([elements count]) {
        for (NSDictionary *element in elements) {
            
            if ([[element objectForKey:@"runorder"] isEqualToString:@"present"] &&
                [[element objectForKey:@"type"] isEqualToString:@"Music"]) {
                NSString *imageURL = [element objectForKey:@"imgurl"];
                if (imageURL)
                    [metadata setObject:[NSURL URLWithString:imageURL] forKey:@"coverArtImageURL"];
                
                NSString *artist = [element objectForKey:@"contributor"];
                if (artist)
                    [metadata setObject:artist forKey:@"currentArtist"];
                
                NSString *title = [element objectForKey:@"title"];
                if (title)
                    [metadata setObject:title forKey:@"currentTrackTitle"];

            } else if ([[element objectForKey:@"runorder"] isEqualToString:@"nextprogram"]) {
                NSDictionary *nextProgram = [element objectForKey:@"program"];
                [metadata setObject:[nextProgram objectForKey:@"title"] forKey:@"nextShowName"];
            }
            
        }
    }
    
    NSLog(@"Posting metadata update notification...");
    NSLog(@"Parsed metadata %@", metadata);
    [[NSNotificationCenter defaultCenter] postNotificationName:GWRadioStationMetadataDidChangeNotification object:self userInfo:metadata];
}



@end
