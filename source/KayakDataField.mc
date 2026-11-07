using Toybox.Application as App;
using Toybox.Activity as Activity;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

class KayakDataFieldApp extends App.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        return [ new KayakDataFieldView() ];
    }
}

class KayakDataFieldView extends Ui.DataField {
    hidden var mLastMetrics;

    function initialize() {
        DataField.initialize();
        mLastMetrics = {
            :strokeRate => 0,
            :stamina => 100,
            :power => 0,
            :effort => 0
        };
    }

    function onLayout(dc) {
        return true;
    }

    function onUpdate(dc) {
        var info = Activity.getActivityInfo();
        var metrics = KayakMetrics.compute(info);
        mLastMetrics = metrics;

        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        dc.clear();

        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, 8, Gfx.FONT_SMALL, "KAYAK", Gfx.TEXT_JUSTIFY_CENTER);

        drawMetric(dc, "STR", metrics[:strokeRate], 8, 28, true);
        drawMetric(dc, "STM", metrics[:stamina], dc.getWidth() - 8, 28, false);

        drawMetric(dc, "W", metrics[:power], 8, 52, true);
        drawMetric(dc, "EFF", metrics[:effort], dc.getWidth() - 8, 52, false);

        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawLine(8, 82, dc.getWidth() - 8, 82);

        dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, 90, Gfx.FONT_TINY, "EST. LIVE", Gfx.TEXT_JUSTIFY_CENTER);
    }

    function drawMetric(dc, label, value, x, y, leftAligned) {
        var text = label + " " + formatValue(value, label);
        var justify = leftAligned ? Gfx.TEXT_JUSTIFY_LEFT : Gfx.TEXT_JUSTIFY_RIGHT;
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x, y, Gfx.FONT_SMALL, text, justify);
    }

    function formatValue(value, label) {
        if (value == null) {
            value = 0;
        }

        if (label == "STR" or label == "W") {
            return value.format("%.0f");
        } else if (label == "STM" or label == "EFF") {
            return value.format("%.0f");
        }

        return value.format("%.0f");
    }
}

class KayakMetrics {
    static function compute(info) {
        var speedMps = info.currentSpeed != null ? info.currentSpeed : 0.0;
        var heartRate = info.currentHeartRate != null ? info.currentHeartRate : 0;
        var cadence = info.currentCadence != null ? info.currentCadence : 0;
		var speedKmh = speedMps * 3.6;

        var strokeRate = estimateStrokeRate(speedMps, speedKmh, heartRate, cadence);
        var power = estimatePower(speedMps, speedKmh, heartRate, cadence);
        var effort = estimateEffort(power, heartRate);
        var stamina = estimateStamina(heartRate, speedKmh, power);

        return {
            :strokeRate => strokeRate,
            :stamina => stamina,
            :power => power,
            :effort => effort
        };
    }

    static function estimateStrokeRate(speedMps, speedKmh, heartRate, cadence) {
        if (speedMps <= 0.15) {
            return 0;
        }

        if (cadence > 0) {
            return clamp(cadence, 0, 120);
        }

        var base = speedKmh * 4.7;
        var hrBoost = heartRate * 0.08;
        return clamp(base + hrBoost, 0, 120);
    }

    static function estimatePower(speedMps, speedKmh, heartRate, cadence) {
        var speedComponent = speedKmh * 2.8;
        var heartRateComponent = heartRate * 0.75;
        var cadenceComponent = cadence * 0.42;
        var power = speedComponent + heartRateComponent + cadenceComponent + 12.0;
        return clamp(power, 0, 900);
    }

    static function estimateEffort(power, heartRate) {
        var powerRatio = power / 500.0;
        var hrRatio = heartRate / 190.0;
        var effort = (powerRatio * 55.0) + (hrRatio * 45.0);
        return clamp(effort, 0, 100);
    }

    static function estimateStamina(heartRate, speedKmh, power) {
        var load = (heartRate / 200.0) * 65.0;
        var paceCost = speedKmh * 0.35;
        var outputBoost = power * 0.025;
        var stamina = 100.0 - load - paceCost + outputBoost;
        return clamp(stamina, 0, 100);
    }

    static function clamp(value, minValue, maxValue) {
        if (value < minValue) {
            return minValue;
        }
        if (value > maxValue) {
            return maxValue;
        }
        return value;
    }
}
