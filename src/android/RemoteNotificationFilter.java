/**
 * © 2017 Plot Projects
 * https://www.plotprojects.com
 */
package com.plotprojects.cordova;

import com.plotprojects.retail.android.FilterableNotification;
import com.plotprojects.retail.android.NotificationFilterReceiver;

import java.util.List;

public class RemoteNotificationFilter extends NotificationFilterReceiver {

    private PlotRemoteHandler remoteHandler;

    @Override
    public void onCreate() {
        super.onCreate();

        remoteHandler = new PlotRemoteHandler(this);
    }

    @Override
    public List<FilterableNotification> filterNotifications(List<FilterableNotification> list) {
        return remoteHandler.filterableNotifications(list);
    }
}
