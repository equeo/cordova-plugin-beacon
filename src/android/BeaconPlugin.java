package de.equeo.cordova.plugins.beacon;

import android.util.Log;

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

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

public class BeaconPlugin extends CordovaPlugin implements MonitorNotifier, RangeNotifier {

    public static final String TAG = "BeaconPlugin";
    public static final String BEACON_LAYOUT = "m:0-3=4c000215,i:4-19,i:20-21,i:22-23,p:24-24";

    private BeaconManager beaconManager;
    private final Map<String, CallbackContext> monitorCallbackMap = new HashMap<>();
    private final Map<String, CallbackContext> rangeCallbackMap = new HashMap<>();

    @Override
    public void pluginInitialize() {
        Log.d(TAG, "pluginInitialize");
        beaconManager = BeaconManager.getInstanceForApplication(cordova.getActivity());
        beaconManager.getBeaconParsers().add(new BeaconParser().setBeaconLayout(BEACON_LAYOUT));
        beaconManager.addMonitorNotifier(this);
        beaconManager.addRangeNotifier(this);
    }

    private Region regionFromJSON(JSONObject regionObject) throws JSONException {
        String uniqueId = regionObject.getString("uniqueId");
        try {
            JSONArray identifiersJSONArray = regionObject.getJSONArray("identifiers");
            ArrayList<Identifier> identifiers = new ArrayList<>();
            for (int index = 0; index < identifiersJSONArray.length(); index++) {
                String current = identifiersJSONArray.getString(index);
                if (current.equals("null")) identifiers.add(null);
                else identifiers.add(Identifier.parse(current));
            }
            return new Region(uniqueId, identifiers);
        } catch (JSONException e) {
            return new Region(uniqueId, null, null, null);
        }

    }

    private JSONObject regionToJSON(Region region) throws JSONException {
        JSONObject regionObject = new JSONObject();
        regionObject.put("uniqueId", region.getUniqueId());
        JSONArray identifiersJSONArray = new JSONArray();
        for (Identifier id : region.getIdentifiers()) {
            if (id == null) identifiersJSONArray.put(null);
            else identifiersJSONArray.put(id.toString());
        }
        regionObject.put("identifiers", identifiersJSONArray);
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
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) {
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

    private void startMonitoring(Region region, CallbackContext ctx) {
        Log.d(TAG, "startMonitoring");

        try {
            assert !monitorCallbackMap.containsKey(region.getUniqueId());

            beaconManager.startMonitoring(region);
            monitorCallbackMap.put(region.getUniqueId(), ctx);

            JSONObject resultData = new JSONObject();
            resultData.put("type", "meta");

            resultData.put("message", PluginResult.Status.OK);

            PluginResult result = new PluginResult(PluginResult.Status.OK, resultData);
            result.setKeepCallback(true);
            ctx.sendPluginResult(result);
        } catch (AssertionError e) {
            PluginResult result = new PluginResult(PluginResult.Status.ERROR, "Already monitoring for Region " + region.getUniqueId() + ".");
            result.setKeepCallback(true);
            ctx.sendPluginResult(result);
        } catch (JSONException e) {
            PluginResult result = new PluginResult(PluginResult.Status.JSON_EXCEPTION, e.getMessage());
            result.setKeepCallback(true);
            ctx.sendPluginResult(result);
        }
    }

    private void stopMonitoring(Region region, CallbackContext ctx) {
        Log.d(TAG, "stopMonitoring");

        beaconManager.stopMonitoring(region);

        try {
            CallbackContext monitorCtx = monitorCallbackMap.get(region.getUniqueId());
            assert monitorCtx != null;

            JSONObject resultData = new JSONObject();
            resultData.put("type", "meta");

            resultData.put("message", PluginResult.Status.OK);

            PluginResult result = new PluginResult(PluginResult.Status.OK, resultData);
            result.setKeepCallback(false);
            monitorCtx.sendPluginResult(result);

            monitorCallbackMap.remove(region.getUniqueId());
        } catch (AssertionError e) {
            ctx.error("Not monitoring for Region " + region.getUniqueId() + ".");
        } catch (JSONException e) {
            PluginResult result = new PluginResult(PluginResult.Status.JSON_EXCEPTION, e.getMessage());
            result.setKeepCallback(false);
            ctx.sendPluginResult(result);
        }
    }

    private void startRanging(Region region, CallbackContext ctx) {
        Log.d(TAG, "startRanging");

        try {
            assert !rangeCallbackMap.containsKey(region.getUniqueId());

            beaconManager.startRangingBeacons(region);
            rangeCallbackMap.put(region.getUniqueId(), ctx);

            JSONObject resultData = new JSONObject();
            resultData.put("type", "meta");

            resultData.put("message", PluginResult.Status.OK);

            PluginResult result = new PluginResult(PluginResult.Status.OK, resultData);
            result.setKeepCallback(true);
            ctx.sendPluginResult(result);
        } catch (AssertionError e) {
            PluginResult result = new PluginResult(PluginResult.Status.ERROR, "Already ranging for Region " + region.getUniqueId() + ".");
            result.setKeepCallback(true);
            ctx.sendPluginResult(result);
        } catch (JSONException e) {
            PluginResult result = new PluginResult(PluginResult.Status.JSON_EXCEPTION, e.getMessage());
            result.setKeepCallback(true);
            ctx.sendPluginResult(result);
        }
    }

    private void stopRanging(Region region, CallbackContext ctx) {
        Log.d(TAG, "stopRanging");

        beaconManager.stopRangingBeacons(region);

        try {
            CallbackContext regionCtx = rangeCallbackMap.get(region.getUniqueId());
            assert regionCtx != null;

            JSONObject resultData = new JSONObject();
            resultData.put("type", "meta");

            resultData.put("message", PluginResult.Status.OK);

            PluginResult result = new PluginResult(PluginResult.Status.OK, resultData);
            result.setKeepCallback(false);
            regionCtx.sendPluginResult(result);
        } catch (AssertionError e) {
            ctx.error("Not ranging for Region " + region.getUniqueId() + ".");
        } catch (JSONException e) {
            PluginResult result = new PluginResult(PluginResult.Status.JSON_EXCEPTION, e.getMessage());
            result.setKeepCallback(false);
            ctx.sendPluginResult(result);
        }

        rangeCallbackMap.remove(region.getUniqueId());
    }

    @Override
    public void didEnterRegion(Region region) {
        Log.d(TAG, "didEnterRegion");
    }

    @Override
    public void didExitRegion(Region region) {
        Log.d(TAG, "didExitRegion");
    }

    @Override
    public void didDetermineStateForRegion(int state, Region region) {
        Log.d(TAG, "didDetermineStateForRegion");

        CallbackContext ctx = monitorCallbackMap.get(region.getUniqueId());
        if (ctx == null) return;

        try {
            JSONObject resultData = new JSONObject();
            resultData.put("type", "data");

            JSONObject messageObject = regionToJSON(region);
            messageObject.put("state", state);
            resultData.put("message", messageObject);

            PluginResult result = new PluginResult(PluginResult.Status.OK, resultData);
            result.setKeepCallback(true);
            ctx.sendPluginResult(result);
        } catch (JSONException e) {
            PluginResult result = new PluginResult(PluginResult.Status.JSON_EXCEPTION, e.getMessage());
            result.setKeepCallback(true);
            ctx.sendPluginResult(result);
        }
    }

    @Override
    public void didRangeBeaconsInRegion(Collection<Beacon> beacons, Region region) {
        Log.d(TAG, "didRangeBeaconsInRegion");

        CallbackContext ctx = rangeCallbackMap.get(region.getUniqueId());
        if (ctx == null) return;

        try {
            JSONObject resultData = new JSONObject();
            resultData.put("type", "data");

            JSONObject messageObject = regionToJSON(region);
            messageObject.remove("identifiers");

            JSONArray beaconsArray = new JSONArray();
            for (Beacon beacon : beacons)
                beaconsArray.put(beaconToJSON(beacon));
            messageObject.put("beacons", beaconsArray);

            resultData.put("message", messageObject);

            PluginResult result = new PluginResult(PluginResult.Status.OK, resultData);
            result.setKeepCallback(true);
            ctx.sendPluginResult(result);
        } catch (JSONException e) {
            PluginResult result = new PluginResult(PluginResult.Status.JSON_EXCEPTION, e.getMessage());
            result.setKeepCallback(true);
            ctx.sendPluginResult(result);
        }
    }

}