# Background Task Setup Guide

## 🔧 Fixing the Info.plist Conflict

The error "Multiple commands produce Info.plist" occurs because Xcode is automatically generating an Info.plist file while we tried to create a manual one. Here's how to fix it:

## ✅ Solution: Add Background Task Configuration to Project Settings

### Step 1: Open Project Settings

1. **Open Xcode**
2. **Select your project** in the navigator
3. **Select the CRIPiOSApp target**
4. **Go to the "Info" tab**

### Step 2: Add Background Task Configuration

In the "Custom iOS Target Properties" section, add these keys:

#### 1. Background Modes
- **Key**: `UIBackgroundModes`
- **Type**: Array
- **Value**: Add item `background-app-refresh`

#### 2. Background Task Identifiers
- **Key**: `BGTaskSchedulerPermittedIdentifiers`
- **Type**: Array
- **Value**: Add item `com.cripiosapp.deathcheck`

### Step 3: Alternative Method (Using Property List Editor)

If you prefer to edit the raw property list:

1. **Right-click on your project** in Xcode
2. **Select "Open As" → "Property List"**
3. **Add the following entries**:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>background-app-refresh</string>
</array>
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.cripiosapp.deathcheck</string>
</array>
```

## 🛠️ Manual Steps in Xcode

### Method 1: Using Xcode Interface

1. **Select your project** in the navigator
2. **Select CRIPiOSApp target**
3. **Go to "Info" tab**
4. **Click the "+" button** to add new keys
5. **Add these keys**:

| Key | Type | Value |
|-----|------|-------|
| `UIBackgroundModes` | Array | `background-app-refresh` |
| `BGTaskSchedulerPermittedIdentifiers` | Array | `com.cripiosapp.deathcheck` |

### Method 2: Using Build Settings

1. **Go to "Build Settings" tab**
2. **Search for "Info.plist"**
3. **Add these build settings**:

```
INFOPLIST_KEY_UIBackgroundModes = background-app-refresh
INFOPLIST_KEY_BGTaskSchedulerPermittedIdentifiers = com.cripiosapp.deathcheck
```

## 🔍 Verification Steps

### Step 1: Clean and Build

1. **Clean Build Folder**: `Product` → `Clean Build Folder`
2. **Build Project**: `Product` → `Build`

### Step 2: Check Generated Info.plist

1. **Find the generated Info.plist** in the build products
2. **Verify it contains**:
   ```xml
   <key>UIBackgroundModes</key>
   <array>
       <string>background-app-refresh</string>
   </array>
   <key>BGTaskSchedulerPermittedIdentifiers</key>
   <array>
       <string>com.cripiosapp.deathcheck</string>
   </array>
   ```

### Step 3: Test Background Tasks

1. **Run the app**
2. **Check console for**: `✅ Background task registered successfully`
3. **Test death detection**: Should work without errors

## 🚨 Common Issues

### Issue 1: Still Getting Multiple Info.plist Error

**Solution**:
1. **Delete any manual Info.plist files**
2. **Clean build folder**
3. **Restart Xcode**
4. **Rebuild project**

### Issue 2: Background Tasks Still Not Working

**Solution**:
1. **Check device settings**: Settings → General → Background App Refresh
2. **Enable for your app**
3. **Verify Info.plist contains correct entries**
4. **Test on physical device** (simulator has limitations)

### Issue 3: Build Settings Not Taking Effect

**Solution**:
1. **Clean build folder**
2. **Delete derived data**: `~/Library/Developer/Xcode/DerivedData`
3. **Restart Xcode**
4. **Rebuild project**

## 📱 Testing on Device

### Prerequisites

1. **Background App Refresh Enabled**
   - Settings → General → Background App Refresh
   - Enable for your app

2. **Proper Info.plist Configuration**
   - Verify background modes are set
   - Check task identifiers are registered

3. **Debug Build**
   - Ensure running in debug mode for testing

### Test Steps

1. **Run app on device**
2. **Check console output**:
   ```
   ✅ Background task registered successfully
   ✅ Notification permissions granted
   🚀 Starting CRON service with frequency: Daily
   ```

3. **Test death detection**:
   - Go to Settings → Testing (debug builds)
   - Tap test buttons
   - Verify console output

## 🎯 Expected Results

### Successful Configuration

- ✅ No "Multiple Info.plist" errors
- ✅ Background tasks register successfully
- ✅ Test buttons work on device
- ✅ Death detection functions properly
- ✅ Notifications are sent

### Console Output

```
✅ Background task registered successfully
✅ Notification permissions granted
🚀 Starting CRON service with frequency: Daily
✅ Background task scheduled successfully
🧪 Starting Sophia Leone death detection test...
✅ Test completed: Sophia Leone death detected!
```

## 🔧 Troubleshooting

### If Background Tasks Still Fail

1. **Use Fallback Timer**: The app automatically falls back to local timers
2. **Check Console**: Look for "🔄 Falling back to local timer for testing"
3. **Test Functionality**: Death detection should still work via manual testing

### If Test Buttons Don't Work

1. **Debug Build**: Ensure running in debug mode
2. **Console Check**: Look for error messages
3. **Force Refresh**: Pull to refresh in Celebrities tab
4. **Restart App**: Close and reopen

This setup guide should resolve the Info.plist conflict and get background tasks working properly. 