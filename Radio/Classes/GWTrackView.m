//
//  GWTrackView.m
//  Radio
//
//  Created by Øystein Riiser Gundersen on 19.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/CALayer.h>

#import "GWTrackView.h"
#import "UIImageView+AFNetworking.h"
#import "GWSpotifySearcher.h"

#define GWTrackViewMetadataLeftOffset 78.0
#define GWTrackViewMetadataDefaultWidth 145.0

@implementation GWTrackView
@synthesize coverArtView;
@synthesize trackLabel;
@synthesize artistLabel;
@synthesize label;
@synthesize spotifyButton;

- (void)loadSubview {
    NSArray *b = [[NSBundle mainBundle] loadNibNamed:@"GWTrackView" owner:self options:nil];
    for (id v in b) {
        if ([v isKindOfClass:[UIView class]])
            [self addSubview:v];
    }
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self loadSubview];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self loadSubview];
        [[[self coverArtView] layer] setMasksToBounds:YES];
        [[[self coverArtView] layer] setBorderColor:[UIColor whiteColor].CGColor];
        [[[self coverArtView] layer] setBorderWidth:1];
    }
    return self;
}

- (void)configureWithTrackData:(NSDictionary *)trackData {
    if (trackData == nil) {
        [self setHidden:YES];
        return;
    }
    
    NSURL *coverArtURL = [trackData objectForKey:@"coverArtImageURL"];
    
    if (coverArtURL)
        [[self coverArtView] setImageWithURLRequest:[NSURLRequest requestWithURL:coverArtURL] placeholderImage:nil 
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                if ([[self label] tag] == GWTrackViewTagCurrent)
                                                    [[NSNotificationCenter defaultCenter] 
                                                     postNotificationName:@"GWCurrentTrackImageDidLoadNotification" object:image];
                                            }
                                            failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                [[self coverArtView] setImage:nil];
                                            }];
    else
        [[self coverArtView] setImage:nil];
        
    NSString *artist = [trackData objectForKey:@"artist"];
    artist = (artist == nil) ? @"" : artist;
    [[self artistLabel] setText:artist];
    
    NSString *title = [trackData objectForKey:@"track"];
    title = (title == nil) ? @"" : title;
    [[self trackLabel] setText:title];
    
    [self setHidden:NO];
    
}

- (IBAction)didTouchSpotifyButton:(UIButton *)sender {
    // TODO: handle empty data
    [GWSpotifySearcher searchForTrack:[[[self trackLabel] text] lowercaseString] 
                             byArtist:[[[self artistLabel] text] lowercaseString]];
    
}


@end
