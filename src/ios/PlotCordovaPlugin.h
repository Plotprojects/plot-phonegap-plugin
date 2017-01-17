//
//  PlotCordovaPlugin.h
//
//

#import <Foundation/Foundation.h>
#import "Plot.h"
#import "PlotRemoteHandler.h"

#import <Cordova/CDV.h>

@interface PlotCordovaPlugin : CDVPlugin<PlotDelegate> {
    PlotFilterNotifications* filterNotifications;
    
    PlotRemoteHandler* remoteHandler;
    
    NSTimer* filterNotificationsTimeoutTimer;
}

@end
