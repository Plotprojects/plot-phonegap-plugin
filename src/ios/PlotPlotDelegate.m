//
//  PlotPlotDelegate.m
//  https://www.plotprojects.com/
//

#import <Foundation/Foundation.h>
#import "Plot.h"
#import "PlotPlotDelegate.h"

@implementation PlotPlotDelegate
@synthesize delegate;

-(instancetype)init {
	if ((self = [super init])) {
		notificationsToHandle = [[NSMutableArray alloc] init];
		notificationsToFilter = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void)plotHandleNotification:(UNNotificationRequest*)notification data:(NSString*)data {
    if (self.delegate) {
        [self.delegate plotHandleNotification:notification data:data];
    } else {
        [notificationsToHandle addObject:notification];
    }
}

-(void)plotFilterNotifications:(PlotFilterNotifications*)notification {
    if (self.delegate) {
        [self.delegate plotFilterNotifications:notification];
    } else {
        [notificationsToFilter addObject:notification];
    }
}

-(NSArray<UNNotificationRequest*>*)notificationsToHandle {
		NSArray* result = [NSArray arrayWithArray:notificationsToHandle];
		[notificationsToHandle removeAllObjects];
    return result;
}

-(NSArray<PlotFilterNotifications*>*)notificationsToFilter {
		NSArray* result = [NSArray arrayWithArray:notificationsToFilter];
		[notificationsToFilter removeAllObjects];
    return result;
}

@end

