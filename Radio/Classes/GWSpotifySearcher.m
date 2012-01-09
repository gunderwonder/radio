//
//  GWSpotifySearcher.m
//  Radio
//
//  Created by Øystein Riiser Gundersen on 18.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GWSpotifySearcher.h"

@implementation GWSpotifySearcher

+ (void)searchForTrack:(NSString *)trackName byArtist:(NSString *)artistName {
    NSLog(@"Searching for '%@' by '%@'", trackName, artistName);
    
    NSString *searchString = [NSString stringWithFormat:@"artist:%@+title:%@", 
                              [artistName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], 
                              [trackName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], nil];
    NSString *localURLString = [NSString stringWithFormat:@"spotify:search:%@", searchString, nil];
    NSString *HTTPURLString = [NSString stringWithFormat:@"http://open.spotify.com/search/%@", searchString, nil];
    
    
    NSLog(@"%@", localURLString);
#ifdef DEBUG
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Spotify" 
                                                        message:localURLString 
                                                       delegate:self 
                                              cancelButtonTitle:@"Avbryt" 
                                              otherButtonTitles:nil];
#else
    
    if ([GWSpotifySearcher canOpenSpotify])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:localURLString]];
    
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Spotify" 
//                               message:@"Spotify er ikke installert. Søk i Safari?" 
//                              delegate:self 
//                     cancelButtonTitle:@"Avbryt" 
//                     otherButtonTitles:@"OK", nil];
//    [alertView show];

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Spotify" 
                                                        message:@"Spotify er ikke installert på enheten." 
                                                       delegate:self 
                                              cancelButtonTitle:@"Avbryt" 
                                              otherButtonTitles:nil];
#endif
    [alertView show];

    
}

+ (BOOL)canOpenSpotify {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"spotify:"]];
}

@end
