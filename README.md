# Garmin Connect IQ kayak data field
#
# This project is a custom data field for a Garmin Forerunner 970 or similar device.
# It is designed to show live estimated kayak metrics while a standard Garmin activity runs.
#
# Notes:
# - The values are estimates based on available sensor data such as speed, cadence, and HR.
# - Garmin native stamina / stroke count metrics are not directly exposed to custom data fields.
# - This project is meant for real-time dashboarding and custom analysis.
# - For true post-workout charting in Garmin Connect, a developer FIT field or a full activity app
#   may be required depending on device support.

# Build in VS Code with the Monkey C extension:
#   1. Install Connect IQ SDK and Monkey C extension.
#   2. Open this folder in VS Code.
#   3. Select the project product(s) with "Monkey C: Edit Products".
#   4. Build with "Monkey C: Build for Device".

