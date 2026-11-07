using Toybox.Application as App;
using Toybox.Activity as Activity;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.FitContributor as Fit;
using Toybox.Math as Math;

class KayakDataFieldApp extends App.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        return [ new KayakDataFieldView() ];
    }
}

class KayakDataFieldView extends Ui.DataField {
    hidden var mFields;

    function initialize() {
        DataField.initialize();

        // Record custom developer fields in each activity record. Check target-device
        // support in the installed Connect IQ SDK; Garmin Connect may not chart all fields.
        mFields = {
            :stroke => createField("kayak_stroke_rate", 0, Fit.DATA_TYPE_UINT16,
                { :mesgType => Fit.MESG_TYPE_RECORD, :units => "spm" }),
            :power => createField("kayak_est_power", 1, Fit.DATA_TYPE_UINT16,
                { :mesgType => Fit.MESG_TYPE_RECORD, :units => "W" }),
            :stamina => createField("kayak_est_stamina", 2, Fit.DATA_TYPE_UINT8,
                { :mesgType => Fit.MESG_TYPE_RECORD, :units => "%" }),
            :effort => createField("kayak_effort_index", 3, Fit.DATA_TYPE_UINT8,
                { :mesgType => Fit.MESG_TYPE_RECORD, :units => "%" })
        };
    }

    function onLayout(dc) {
        return true;
    }

    function onUpdate(dc) {
        var info = Activity.getActivityInfo();
        var metrics = KayakMetrics.compute(info, App.getApp());

        mFields[:stroke].setData(Math.round(metrics[:strokeRate]));
        mFields[:power].setData(Math.round(metrics[:power]));
        mFields[:stamina].setData(Math.round(metrics[:stamina]));
        mFields[:effort].setData(Math.round(metrics[:effort]));

        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        dc.clear();
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, 8, Gfx.FONT_SMALL, "KAYAK EST.", Gfx.TEXT_JUSTIFY_CENTER);

        drawMetric(dc, "STR spm", metrics[:strokeRate], 8, 29, true);
        drawMetric(dc, "STM %", metrics[:stamina], dc.getWidth() - 8, 29, false);
        drawMetric(dc, "W est", metrics[:power], 8, 54, true);
        drawMetric(dc, "EFF %", metrics[:effort], dc.getWidth() - 8, 54, false);

        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawLine(8, 82, dc.getWidth() - 8, 82);
        dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, 90, Gfx.FONT_TINY, "ESTIMATES - NOT MEASURED", Gfx.TEXT_JUSTIFY_CENTER);
    }

    function drawMetric(dc, label, value, x, y, leftAligned) {
        var text = label + " " + value.format("%.0f");
        var justify = leftAligned ? Gfx.TEXT_JUSTIFY_LEFT : Gfx.TEXT_JUSTIFY_RIGHT;
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x, y, Gfx.FONT_SMALL, text, justify);
    }
}

class KayakMetrics {
    static function compute(info, app) {
        var speedMps = (info != null && info.currentSpeed != null) ? info.currentSpeed : 0.0;
        var heartRate = (info != null && info.currentHeartRate != null) ? info.currentHeartRate : 0;
        var cadence = (info != null && info.currentCadence != null) ? info.currentCadence : 0;
        var speedKmh = speedMps * 3.6;

        var powerScale = readSetting(app, "powerScale", 100) / 100.0;
        var strokeScale = readSetting(app, "strokeScale", 100) / 100.0;

        var strokeRate = estimateStrokeRate(speedMps, speedKmh, heartRate, cadence) * strokeScale;
        var power = estimatePower(speedKmh, heartRate, cadence) * powerScale;
        var effort = estimateEffort(power, heartRate);
        var stamina = estimateStamina(heartRate, speedKmh, power);

        return {
            :strokeRate => clamp(strokeRate, 0, 120),
            :stamina => stamina,
            :power => clamp(power, 0, 1500),
            :effort => effort
        };
    }

    static function readSetting(app, key, fallback) {
        var value = app.getProperty(key);
        return value != null ? value : fallback;
    }

    static function estimateStrokeRate(speedMps, speedKmh, heartRate, cadence) {
        if (speedMps <= 0.15) {
            return 0;
        }
        // Cadence is only a proxy unless the activity/device exposes kayak strokes.
        if (cadence > 0) {
            return cadence;
        }
        return speedKmh * 4.7 + heartRate * 0.08;
    }

    static function estimatePower(speedKmh, heartRate, cadence) {
        // Heuristic only. Calibrate against an independent kayak power source.
        return speedKmh * 2.8 + heartRate * 0.75 + cadence * 0.42 + 12.0;
    }

    static function estimateEffort(power, heartRate) {
        return clamp((power / 500.0) * 55.0 + (heartRate / 190.0) * 45.0, 0, 100);
    }

    static function estimateStamina(heartRate, speedKmh, power) {
        // A displayed training-load estimate, not Garmin Firstbeat Stamina.
        return clamp(100.0 - (heartRate / 200.0) * 65.0 - speedKmh * 0.35 + power * 0.025, 0, 100);
    }

    static function clamp(value, minValue, maxValue) {
        if (value < minValue) { return minValue; }
        if (value > maxValue) { return maxValue; }
        return value;
    }
}
