/**
 * © 2017 Plot Projects
 * https://www.plotprojects.com
 */
package com.plotprojects.cordova;

import com.plotprojects.retail.android.Geotrigger;
import com.plotprojects.retail.android.GeotriggerHandlerReceiver;

import java.util.List;

public class RemoteGeotriggerHandler extends GeotriggerHandlerReceiver {

    private PlotRemoteHandler remoteHandler;

    @Override
    public void onCreate() {
        super.onCreate();

        remoteHandler = new PlotRemoteHandler(this);
    }

    @Override
    public List<Geotrigger> handleGeotriggers(List<Geotrigger> list) {
        remoteHandler.sendGeotriggers(list);
        return list;
    }
}
