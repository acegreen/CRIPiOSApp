# Death Alert Testing Guide

## 🧪 Testing Death Alerts with Sophia Leone

This guide shows you how to test the death alert functionality using Sophia Leone as a real-world example. According to the [New York Post article](https://nypost.com/2024/03/10/us-news/porn-star-sophia-leone-dead-at-26/), Sophia Leone passed away on March 1, 2024, at the age of 26.

## 📱 How to Test

### Method 1: Using the App Interface (Debug Builds Only)

1. **Open the App**
   - Launch the CRIP iOS App in **Debug** mode
   - Navigate to the **Settings** tab

2. **Find the Testing Section**
   - Scroll down to the **"Testing"** section (only visible in debug builds)
   - You'll see two test buttons:
     - 🧪 **"Test Sophia Leone Death Detection"** (Orange)
     - ▶️ **"Test Full Death Check Process"** (Blue)

3. **Run the Tests**
   - Tap **"Test Sophia Leone Death Detection"** for a focused test
   - Tap **"Test Full Death Check Process"** for a comprehensive test
   - Watch the console output for detailed information

### Method 2: Unit Tests (Recommended)

1. **Run Unit Tests**
   - Open the project in Xcode
   - Go to **Product** → **Test** (⌘+U)
   - Or run specific tests in the test navigator

2. **Available Test Cases**
   - `testSophiaLeoneDeathDetection()` - Tests Sophia Leone death detection
   - `testFullDeathCheckProcess()` - Tests complete death check process
   - `testCronFrequencyTimeIntervals()` - Tests CRON frequency settings
   - `testCronFrequencyDisplayNames()` - Tests display names
   - `testDeathCheckServiceInitialization()` - Tests service initialization
   - `testCronServiceInitialization()` - Tests CRON service setup
   - `testCelebrityDeathStatusUpdate()` - Tests celebrity status updates
   - `testUserDefaultsPersistence()` - Tests data persistence

### Method 3: Manual Testing

1. **Check Current Status**
   - Go to the **Celebrities** tab
   - Search for "Sophia Leone"
   - Note that she's currently marked as **alive** (age 27, no death date)

2. **Run Death Check**
   - Go to **Settings** → **Background Death Checks**
   - Tap **"Check for Deaths Now"**
   - This will trigger the actual death detection process

3. **Verify Results**
   - Return to the **Celebrities** tab
   - Search for "Sophia Leone" again
   - She should now be marked as **deceased** with death date "March 1, 2024"

## 🔍 What the Tests Do

### Test 1: Sophia Leone Death Detection
```
🧪 Testing death detection for Sophia Leone...
✅ Found Sophia Leone in database (currently marked as alive)
   Name: Sophia Leone
   Age: 27
   Occupation: Adult Actress
   Currently Deceased: false

🔍 Simulating death check from Wikipedia/Wikidata...
   Found death date: March 1, 2024
   Cause of death: Under investigation (robbery and homicide)

📝 Updating Sophia Leone's record...
   New status: Deceased
   Death date: March 1, 2024
   Age at death: 26

✅ Death detection test completed!
   Sophia Leone has been marked as deceased
   Notification would be sent to user
   Database has been updated
```

### Test 2: Full Death Check Process
```
🧪 Starting full death check process test...
📊 Current database status:
   Total celebrities: 30
   Living celebrities: 15
   Deceased celebrities: 15

🔍 Checking living celebrities for death information...
   Checking: Tom Hanks (67 years old)
   ✅ Tom Hanks is still alive
   Checking: Meryl Streep (74 years old)
   ✅ Meryl Streep is still alive
   Checking: Morgan Freeman (87 years old)
   ✅ Morgan Freeman is still alive
   Checking: Sophia Leone (27 years old)
   ❌ Found death information for Sophia Leone
   Checking: Michelle Trachtenberg (39 years old)
   ✅ Michelle Trachtenberg is still alive

📝 Updating database with new deaths...
🔔 Sending death notifications...
   📱 Notification: 'Sophia Leone has passed away'

✅ Death check process completed!
   New deaths found: 1
   Database updated
   Notifications sent
```

## 📊 Expected Results

### Before Test
- **Sophia Leone**: Alive, Age 27, No death date
- **Status**: `isDeceased: false`

### After Test
- **Sophia Leone**: Deceased, Age 26, Death date: March 1, 2024
- **Status**: `isDeceased: true`
- **Cause of Death**: "Under investigation (robbery and homicide)"

## 🔔 Notification Testing

### Push Notification
When a death is detected, the app will send a push notification:
- **Title**: "Celebrity Death Alert"
- **Body**: "Sophia Leone has passed away"
- **Subtitle**: "Adult Actress"
- **Sound**: Default notification sound

### In-App Updates
- The celebrity's status updates immediately in the database
- The UI refreshes to show the new deceased status
- The celebrity appears in the "Recent Deaths" section

## 🛠️ Technical Details

### What Happens During Testing

1. **Database Query**: The system finds Sophia Leone in the current celebrity database
2. **API Simulation**: Simulates a call to Wikipedia/Wikidata APIs (in real scenario)
3. **Death Detection**: Finds death information (March 1, 2024)
4. **Data Update**: Creates new celebrity record with death information
5. **UI Update**: Updates the view model and refreshes the UI
6. **Notification**: Sends push notification to the user

### Real-World Scenario

In production, the process would be:
1. **Background Task**: CRON service runs automatically based on frequency
2. **API Calls**: Real calls to Wikipedia/Wikidata for each living celebrity
3. **Death Verification**: Cross-references multiple sources for accuracy
4. **Database Update**: Updates celebrity records with death information
5. **User Notification**: Sends push notifications for new deaths
6. **UI Refresh**: Updates the app interface to reflect changes

## 🎯 Testing Different Scenarios

### Scenario 1: New Death Detection
- **Test**: Sophia Leone death detection
- **Expected**: Status changes from alive to deceased
- **Result**: Notification sent, database updated

### Scenario 2: No New Deaths
- **Test**: Check other living celebrities
- **Expected**: No status changes
- **Result**: No notifications, database unchanged

### Scenario 3: Multiple Deaths
- **Test**: Simulate multiple celebrity deaths
- **Expected**: Multiple status changes
- **Result**: Multiple notifications sent

## 🔧 Troubleshooting

### Common Issues

1. **Test Button Not Working**
   - Ensure you're running in **Debug** mode
   - Check console for error messages
   - Verify CelebrityViewModel.shared is set

2. **No Console Output**
   - Check Xcode console for print statements
   - Ensure debug logging is enabled
   - Verify test functions are being called

3. **UI Not Updating**
   - Check if MainActor.run is being called
   - Verify view model updates are triggering UI refresh
   - Ensure celebrity data is being properly updated

4. **Unit Tests Failing**
   - Check that all dependencies are properly imported
   - Verify test data is correctly set up
   - Ensure UserDefaults cleanup is working

### Debug Information

Enable detailed logging by checking the console for:
- Death detection process steps
- API call simulations
- Database update confirmations
- Notification sending status

## 📈 Performance Testing

### Test Metrics
- **Response Time**: How quickly death detection completes
- **Accuracy**: Correct identification of deceased celebrities
- **Reliability**: Consistent results across multiple test runs
- **User Experience**: Smooth UI updates and notifications

### Expected Performance
- **Death Detection**: < 5 seconds per celebrity
- **Database Update**: < 1 second
- **UI Refresh**: < 500ms
- **Notification**: < 2 seconds

## 🎉 Success Criteria

A successful test should result in:
1. ✅ Sophia Leone marked as deceased
2. ✅ Death date updated to March 1, 2024
3. ✅ Age updated to 26 (age at death)
4. ✅ Push notification received
5. ✅ UI updated to reflect changes
6. ✅ Console shows detailed process logs
7. ✅ Unit tests pass with proper assertions

## 🏗️ Architecture Notes

### Test Organization
- **Unit Tests**: Located in `CRIPiOSAppTests.swift`
- **UI Tests**: Available in debug builds only
- **Integration Tests**: Manual testing through app interface

### Debug vs Release
- **Debug Builds**: Include testing section in Settings
- **Release Builds**: Testing section hidden, only production features visible
- **Unit Tests**: Run in both debug and release configurations

This testing framework allows you to verify that the death alert system works correctly and provides a realistic simulation of how it would function in production with real celebrity death data. 