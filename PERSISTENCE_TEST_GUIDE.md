# Manual Testing Guide for Persistent Counter Functionality

This guide describes how to manually test the persistent counter feature that ensures mouse tracking counters survive app restarts.

## Test Case 1: Basic Persistence Test

### Steps:
1. Launch the Imperial Tracker application
2. Move your mouse around for a few seconds to generate some movement data
3. Click the mouse a few times to generate click data
4. Note the current values displayed:
   - "MOVEMENTS TRACKED" count
   - "CLICK INTERACTIONS" count  
   - "DISTANCE MOVED" value (in pixels)
5. Close the application completely
6. Relaunch the application
7. Verify the counters show the same values from step 4 (or higher if you moved the mouse during relaunch)

### Expected Result:
✅ Counters should persist and NOT reset to zero
❌ If counters reset to zero, persistence is not working

## Test Case 2: Accumulation Test

### Steps:
1. Note the current counter values when app starts
2. Use the mouse actively for 30 seconds (move around and click)
3. Note the new counter values - they should be higher
4. Close and relaunch the app
5. Note the counter values - they should match step 3
6. Use the mouse for another 30 seconds
7. Verify counters continue to increase from the previous session's values

### Expected Result:
✅ Counters should accumulate across sessions
❌ If counters reset or don't accumulate properly, there's an issue

## Test Case 3: Performance Test

### Steps:
1. Launch the app
2. Move the mouse rapidly and continuously for 1-2 minutes
3. Observe the app's responsiveness and performance
4. Close the app
5. Relaunch and verify distance counter persisted

### Expected Result:
✅ App should remain responsive during heavy mouse usage
✅ Distance should be persisted accurately
❌ If app becomes unresponsive or data is lost, there's a performance issue

## Test Case 4: Data Validation

### Steps:
1. Start with fresh app (or note existing values)
2. Perform exactly 10 mouse clicks
3. Note the "CLICK INTERACTIONS" value should increase by exactly 10
4. Move mouse in a large square pattern (to generate measurable distance)
5. Note the "DISTANCE MOVED" should increase proportionally
6. Close and relaunch app
7. Verify both values persisted correctly

### Expected Result:
✅ Click count should be accurate
✅ Distance should be reasonable (not zero, not impossibly large)
✅ Both values should persist across restart

## Technical Notes

- Persistence is implemented using SharedPreferences for local storage
- Distance saves are batched (every 10 mouse movements) for performance
- Click counts are saved immediately for accuracy
- Data is always saved when the app closes (dispose method)
- No internet connection required - all persistence is local

## Troubleshooting

If persistence doesn't work:
1. Check if the app has proper file system permissions
2. Verify SharedPreferences is working on the platform
3. Check app logs for any error messages related to persistence
4. Ensure the app is properly calling dispose when closing

## Success Criteria

The feature is working correctly if:
- ✅ Counters never reset to zero on app restart
- ✅ Values accumulate across multiple sessions  
- ✅ App performance remains good during heavy usage
- ✅ Data persists even after computer restarts
- ✅ UI shows updated values immediately on app launch