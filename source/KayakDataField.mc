using Toybox.Application as App;
using Toybox.Activity as Activity;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Math as Math;
using Toybox.System as Sys;

class KayakDataFieldApp extends App.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        return [ new KayakDataFieldView() ];
    }
}

class KayakDataFieldView extends Ui.DataField {
    hidden var _lastMetrics;

    function initialize() {
        DataField.initialize();
        _lastMetrics = {
            strokeRate => 0,
            stamina => 100,
            power => 0,
            effort => 0
        };
    }

    function onLayout(dc) {
        return true;
    }

    function onUpdate(dc) {
        var info = Activity.getActivityInfo();
        var metrics = KayakMetrics.compute(info);
        _lastMetrics = metrics;

        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        dc.clear();

        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, 12, Gfx.FONT_SMALL, "KAYAK", Gfx.TEXT_JUSTIFY_CENTER);

        var titleY = 36;
        var lineHeight = 20;
        var leftX = 8;
        var rightX = dc.getWidth() - 8;

        drawMetric(dc, "STR", metrics[:strokeRate], leftX, titleY, true);
        drawMetric(dc, "STM", metrics[:stamina], rightX, titleY, false);

        drawMetric(dc, "W", metrics[:power], leftX, titleY + lineHeight, true);
        drawMetric(dc, "EFF", metrics[:effort], rightX, titleY + lineHeight, false);

        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawLine(8, 86, dc.getWidth() - 8, 86);

        dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, 94, Gfx.FONT_TINY, "EST. LIVE", Gfx.TEXT_JUSTIFY_CENTER);
    }

    function drawMetric(dc, label, value, x, y, isLeft) {
        var text = label + " " + formatValue(value, label);
        var justify = isLeft ? Gfx.TEXT_JUSTIFY_LEFT : Gfx.TEXT_JUSTIFY_RIGHT;
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x, y, Gfx.FONT_SMALL, text, justify);
    }

    function formatValue(value, label) {
        if (label == "STR") {
            return value.format("%.0f");
        } else if (label == "STM") {
            return value.format("%.0f");
        } else if (label == "W") {
            return value.format("%.0f");
        } else if (label == "EFF") {
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

        var strokeRate = estimateStrokeRate(speedMps, heartRate, cadence);
        var power = estimatePower(speedMps, heartRate, cadence);
        var effort = estimateEffort(power, heartRate);
        var stamina = estimateStamina(heartRate, speedMps, power);

        return {
            strokeRate => strokeRate,
            stamina => stamina,
            power => power,
            effort => effort
        };
    }

    static function estimateStrokeRate(speedMps, heartRate, cadence) {
        var speedKmh = speedMps * 3.6;

        if (speedMps <= 0.15) {
            return 0;
        }

        if (cadence > 0) {
            return clamp(cadence, 0, 120);
        }

        var base = speedKmh * 4.8;
        var hrBoost = heartRate * 0.08;
        return clamp(base + hrBoost, 0, 120);
    }

    static function estimatePower(speedMps, heartRate, cadence) {
        var speedKmh = speedMps * 3.6;
        var speedComponent = speedKmh * 3.2;
        var heartRateComponent = heartRate * 0.72;
        var cadenceComponent = cadence * 0.45;

        var power = speedComponent + heartRateComponent + cadenceComponent + 14.0;
        return clamp(power, 0, 900);
    }

    static function estimateEffort(power, heartRate) {
        var powerRatio = power / 500.0;
        var hrRatio = heartRate / 190.0;
        var effort = (powerRatio * 55.0) + (hrRatio * 45.0);
        return clamp(effort, 0, 100);
    }

    static function estimateStamina(heartRate, speedMps, power) {
        var load = (heartRate / 200.0) * 70.0;
        var pace = (speedMps * 3.6) * 0.35;
        var output = (power / 12.0) * 0.2;

        var stamina = 100.0 - load - pace + output;
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

