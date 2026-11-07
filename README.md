# This is a lightweight Garmin Connect IQ implementation for a kayak training data field.
#
# Important note:
# - The Connect IQ SDK does not expose Garmin-native Stamina or swim stroke cadence/count values
#   for data fields on devices like the Forerunner 970.
# - This implementation calculates custom, live estimates from the sensors that are normally available
#   (speed, heart rate, cadence, elapsed activity info), which is useful for dashboarding and analysis.
# - These metrics are designed for custom tracking and export, not to replace Garmin's proprietary metrics.
#
# Compile with the Garmin Connect IQ SDK:
#   monkeyc -o kayak-field.prg -f monkey.jungle
#
# Notes:
#   - Data fields are displayed on the watch during activity only.
#   - To analyze data more deeply, export the FIT file from the device or pair the watch with Garmin Connect.
#   - If you want true native Stamina or stroke metrics, they must be provided by Garmin's native activity profiles
#     and are not directly accessible from a custom data field.

