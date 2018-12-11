/**
 * © 2017 Plot Projects
 * https://www.plotprojects.com
 */
package com.plotprojects.cordova;

import com.plotprojects.retail.android.FilterableNotification;
import com.plotprojects.retail.android.NotificationFilterBroadcastReceiver;

import java.util.List;

public class RemoteNotificationFilter extends NotificationFilterBroadcastReceiver {

    @Override
    public List<FilterableNotification> filterNotifications(List<FilterableNotification> notifications) {
        return notifications;
    }
}
