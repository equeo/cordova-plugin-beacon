public class BeaconPlugin extends CordovaPlugin implements MonitorNotifier, RangeNotifier {

    public static final String TAG = "BeaconPlugin";

    public static final String IBEACON_LAYOUT = "m:0-3=4c000215,i:4-19,i:20-21,i:22-23,p:24-24"

    private BeaconManager beaconManager;
    private Map<String, CallbackContext> monitorCallbackMap = new HashMap();
    private Map<String, CallbackContext> rangeCallbackMap = new HashMap();

    @Override
    public void pluginInitialize() {
        beaconManager = BeaconManager.getInstanceForApplication(cordova.getActivity());
        beaconManager.getBeaconParsers().add(new BeaconParser().setBeaconLayout(IBEACON_LAYOUT));
        beaconManager.addMonitorNotifier(this);
        beaconManager.addRangeNotifier(this);
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) {}

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
    }

    @Override
    public void didRangeBeaconsInRegion(Collection<Beacon> beacons, Region region) {
        Log.d(TAG, "didRangeBeaconsInRegion");
    }
}