#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Plot.h"

@interface PlotRemoteHandler : NSObject {
}

-(void)setRemoteNotificationFilter:(NSString*)url;
-(void)setRemoteGeotriggerHandler:(NSString*)url;

-(BOOL)hasRemoteNotificationFilter;
-(BOOL)hasRemoteGeotriggerHandler;

-(void)filterNotifications:(PlotFilterNotifications*)filterNotifications;
-(void)handleGeotriggers:(PlotHandleGeotriggers*)geotriggerHandler;

@end
