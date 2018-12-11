/**
 * © 2017 Plot Projects
 * https://www.plotprojects.com
 */
package com.plotprojects.cordova;

import com.plotprojects.retail.android.Geotrigger;
import com.plotprojects.retail.android.GeotriggerHandlerBroadcastReceiver;

import java.util.List;

public class RemoteGeotriggerHandler extends GeotriggerHandlerBroadcastReceiver {

    @Override
    public List<Geotrigger> handleGeotriggers(List<Geotrigger> geotriggers) {
        return geotriggers;
    }
}
