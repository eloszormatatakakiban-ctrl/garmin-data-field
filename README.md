# Kayak data field for Garmin Connect IQ

This Connect IQ **data field** is intended to be added to the built-in Kayak activity's data screens. It displays estimated stroke rate, power, stamina-like reserve, and effort while the activity is running. Power and stroke scaling can be adjusted in the app settings.

## FIT recording

The data field contributes four custom developer fields to record messages using `Toybox.WatchUi.DataField.createField()` and `setData()`. The Forerunner 970 SDK/device firmware must support developer fields for this use. After building and recording a short test activity, inspect the FIT file and Garmin Connect to confirm whether the fields are retained and graphed; Garmin Connect display behavior can vary and is not guaranteed by this source code alone.

## Important metric limitations

- These are heuristic estimates, not measured kayak power or force.
- `currentCadence` may not represent kayak strokes on the selected activity/device. The fallback stroke estimate is derived from speed and heart rate.
- The stamina-like value is not Garmin's native Firstbeat Stamina.
- Force in newtons and boat stability are not implemented: wrist/watch motion is not a calibrated paddle-force or hull-stability sensor, especially when the watch is mounted on the boat. These require a suitable external sensor and a defined/calibrated algorithm.

## Build and test

1. Open the repository folder in VS Code with the Garmin Monkey C extension and a current Connect IQ SDK.
2. Run **Monkey C: Edit Products** and select Forerunner 970.
3. Run **Monkey C: Build for Device**.
4. Install on the watch, add the field to a Kayak activity screen, and record a short test. Check compilation, live sensor values, and the resulting FIT file before relying on post-workout charts.

This repository has not been built or run in the SDK/device simulator as part of this change.
