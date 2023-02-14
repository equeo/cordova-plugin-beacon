package de.equeo.cordova.plugins.beacon;

import android.util.Log;

import androidx.annotation.NonNull;

import org.altbeacon.beacon.Beacon;
import org.altbeacon.beacon.BeaconManager;
import org.altbeacon.beacon.BeaconParser;
import org.altbeacon.beacon.Identifier;
import org.altbeacon.beacon.RangeNotifier;
import org.altbeacon.beacon.MonitorNotifier;
import org.altbeacon.beacon.Region;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;

import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

public class BeaconPlugin extends CordovaPlugin implements MonitorNotifier, RangeNotifier {

    public static final String TAG = "BeaconPlugin";
    public static final String IBEACON_LAYOUT = "m:0-3=4c000215,i:4-19,i:20-21,i:22-23,p:24-24";

    private BeaconManager beaconManager;
    private Map<String, CallbackContext> monitorCallbackMap = new HashMap();
    private Map<String, CallbackContext> rangeCallbackMap = new HashMap();

    @Override
    public void pluginInitialize() {
        Log.d(TAG, "pluginInitialize");
        beaconManager = BeaconManager.getInstanceForApplication(cordova.getActivity());
        beaconManager.getBeaconParsers().add(new BeaconParser().setBeaconLayout(IBEACON_LAYOUT));
        beaconManager.addMonitorNotifier(this);
        beaconManager.addRangeNotifier(this);
    }

    private Region regionFromJSON(JSONObject regionObject) throws JSONException {
        String uniqueId = regionObject.getString("uniqueId");
        String identifier = regionObject.getString("identifier");
        if (identifier.equals("null")) return new Region(uniqueId, null, null, null);
        return new Region(uniqueId, identifier);
    }

    private JSONObject regionToJSON(Region region) throws JSONException {
        JSONObject regionObject = new JSONObject();
        regionObject.put("uniqueId", region.getUniqueId());
        regionObject.put("identifier", region.getIdentifier(0));
        return regionObject;
    }

    private JSONObject beaconToJSON(Beacon beacon) throws JSONException {
        JSONObject object = new JSONObject();
        object.put("packetCount", beacon.getPacketCount());
        object.put("firstCycleDetectionTimestamp", beacon.getFirstCycleDetectionTimestamp());
        object.put("lastCycleDetectionTimestamp", beacon.getLastCycleDetectionTimestamp());
        object.put("measurementCount", beacon.getMeasurementCount());
        object.put("runningAverageRssi", beacon.getRunningAverageRssi());
        object.put("manufacturer", beacon.getManufacturer());
        object.put("serviceUuid", beacon.getServiceUuid());

        JSONArray dataFields = new JSONArray();
        for (Long data : beacon.getDataFields()) dataFields.put(data.longValue());
        object.put("dataFields", dataFields);

        JSONArray extraDataFields = new JSONArray();
        for (Long data : beacon.getDataFields()) extraDataFields.put(data.longValue());
        object.put("extraDataFields", extraDataFields);

        JSONArray identifiers = new JSONArray();
        for (Identifier id : beacon.getIdentifiers()) identifiers.put(id.toString());
        object.put("identifiers", identifiers);

        object.put("distance", beacon.getDistance());
        object.put("rssi", beacon.getRssi());
        object.put("txPower", beacon.getTxPower());
        object.put("beaconTypeCode", beacon.getBeaconTypeCode());
        object.put("bluetoothAddress", beacon.getBluetoothAddress());
        object.put("bluetoothName", beacon.getBluetoothName());
        object.put("parserIdentifier", beacon.getParserIdentifier());
        object.put("isMultiFrameBeacon", beacon.isMultiFrameBeacon());
        object.put("isExtraBeaconData", beacon.isExtraBeaconData());

        return object;
    }

    @Override
    public boolean execute(@NonNull String action, @NonNull JSONArray args, CallbackContext callbackContext) {
        Log.d(TAG, "execute");
        try {
            Region region = regionFromJSON(args.getJSONObject(0));
            switch (action) {
                case "startMonitoring":
                    startMonitoring(region, callbackContext);
                    break;
                case "stopMonitoring":
                    stopMonitoring(region, callbackContext);
                    break;
                case "startRanging":
                    startRanging(region, callbackContext);
                    break;
                case "stopRanging":
                    stopRanging(region, callbackContext);
                    break;
                default:
                    return false;
            }

        } catch (JSONException e) {
            callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.JSON_EXCEPTION, e.getMessage()));
        }
        return true;
    }

    private void startMonitoring(@NonNull Region region, CallbackContext ctx) {
        Log.d(TAG, "startMonitoring");
        if (monitorCallbackMap.containsKey(region.getUniqueId())) {
            PluginResult result = new PluginResult(PluginResult.Status.ERROR, "Already monitoring for Region " + region.getUniqueId() + ".");
            result.setKeepCallback(true);
            ctx.sendPluginResult(result);
            return;
        }

        beaconManager.startMonitoring(region);

        PluginResult result = new PluginResult(PluginResult.Status.OK, (String) null);
        result.setKeepCallback(true);
        monitorCallbackMap.put(region.getUniqueId(), ctx);
        ctx.sendPluginResult(result);
    }

    private void stopMonitoring(@NonNull Region region, CallbackContext ctx) {
        Log.d(TAG, "stopMonitoring");
        if (!monitorCallbackMap.containsKey(region.getUniqueId())) {
            ctx.error("Not monitoring for Region " + region.getUniqueId() + ".");
            return;
        }

        beaconManager.stopMonitoring(region);

        CallbackContext monitorCtx = monitorCallbackMap.get(region.getUniqueId());
        PluginResult monitorResult = new PluginResult(PluginResult.Status.OK, (String) null);
        monitorResult.setKeepCallback(false);
        monitorCtx.sendPluginResult(monitorResult);

        monitorCallbackMap.remove(region.getUniqueId());
    }

    private void startRanging(@NonNull Region region, CallbackContext ctx) {
        Log.d(TAG, "startRanging");
        if (rangeCallbackMap.containsKey(region.getUniqueId())) {
            PluginResult result = new PluginResult(PluginResult.Status.ERROR, "Already ranging for Region " + region.getUniqueId() + ".");
            result.setKeepCallback(true);
            ctx.sendPluginResult(result);
            return;
        }

        beaconManager.startRangingBeacons(region);

        PluginResult result = new PluginResult(PluginResult.Status.OK, (String) null);
        result.setKeepCallback(true);
        rangeCallbackMap.put(region.getUniqueId(), ctx);
        ctx.sendPluginResult(result);
    }

    private void stopRanging(@NonNull Region region, CallbackContext ctx) {
        Log.d(TAG, "stopRanging");
        if (!rangeCallbackMap.containsKey(region.getUniqueId())) {
            ctx.error("Not monitoring for Region " + region.getUniqueId() + ".");
            return;
        }

        beaconManager.stopRangingBeacons(region);

        CallbackContext regionCtx = rangeCallbackMap.get(region.getUniqueId());
        PluginResult regionResult = new PluginResult(PluginResult.Status.OK, (String) null);
        regionResult.setKeepCallback(false);
        regionCtx.sendPluginResult(regionResult);

        rangeCallbackMap.remove(region.getUniqueId());
    }

    @Override
    public void didEnterRegion(@NonNull Region region) {
        Log.d(TAG, "didEnterRegion");

        CallbackContext ctx = monitorCallbackMap.get(region.getUniqueId());
        if (ctx == null) return;

        try {
            JSONObject regionObject = regionToJSON(region);

            PluginResult result = new PluginResult(PluginResult.Status.OK, regionObject);
            result.setKeepCallback(true);
            ctx.sendPluginResult(result);
        } catch (JSONException e) {
            PluginResult result = new PluginResult(PluginResult.Status.JSON_EXCEPTION, e.getMessage());
            result.setKeepCallback(true);
            ctx.sendPluginResult(result);
        }
    }

    @Override
    public void didExitRegion(@NonNull Region region) {
        Log.d(TAG, "didExitRegion");

        CallbackContext ctx = monitorCallbackMap.get(region.getUniqueId());
        if (ctx == null) return;

        try {
            JSONObject regionObject = regionToJSON(region);

            PluginResult result = new PluginResult(PluginResult.Status.OK, regionObject);
            result.setKeepCallback(true);
            ctx.sendPluginResult(result);
        } catch (JSONException e) {
            PluginResult result = new PluginResult(PluginResult.Status.JSON_EXCEPTION, e.getMessage());
            result.setKeepCallback(true);
            ctx.sendPluginResult(result);
        }
    }

    @Override
    public void didDetermineStateForRegion(int state, @NonNull Region region) {
        Log.d(TAG, "didDetermineStateForRegion");

        CallbackContext ctx = monitorCallbackMap.get(region.getUniqueId());
        if (ctx == null) return;

        try {
            JSONObject regionObject = regionToJSON(region);

            PluginResult result = new PluginResult(PluginResult.Status.OK, regionObject);
            result.setKeepCallback(true);
            ctx.sendPluginResult(result);
        } catch (JSONException e) {
            PluginResult result = new PluginResult(PluginResult.Status.JSON_EXCEPTION, e.getMessage());
            result.setKeepCallback(true);
            ctx.sendPluginResult(result);
        }
    }

    @Override
    public void didRangeBeaconsInRegion(@NonNull Collection<Beacon> beacons, @NonNull Region region) {
        Log.d(TAG, "didRangeBeaconsInRegion");

        CallbackContext ctx = rangeCallbackMap.get(region.getUniqueId());
        if (ctx == null) return;

        try {
            JSONObject regionObject = regionToJSON(region);
            JSONArray beaconsArray = new JSONArray();
            for (Beacon beacon : beacons)
                beaconsArray.put(beaconToJSON(beacon));
            regionObject.put("beacons", beaconsArray);

            PluginResult result = new PluginResult(PluginResult.Status.OK, regionObject);
            result.setKeepCallback(true);
            ctx.sendPluginResult(result);
        } catch (JSONException e) {
            PluginResult result = new PluginResult(PluginResult.Status.JSON_EXCEPTION, e.getMessage());
            result.setKeepCallback(true);
            ctx.sendPluginResult(result);
        }
    }

}