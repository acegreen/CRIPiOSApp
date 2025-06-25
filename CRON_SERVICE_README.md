# CRON Service for Celebrity Death Checks

## Overview

The CRON service is a background task system that periodically checks for celebrity deaths using Wikipedia/Wikidata APIs. It provides automatic notifications when new deaths are detected and allows users to configure the frequency of checks.

## Features

### 🔄 Automatic Background Checks
- **Configurable Frequency**: Hourly, Daily, Weekly, Monthly, or Disabled
- **Background Task Support**: Uses iOS Background App Refresh
- **Smart Detection**: Only checks celebrities that were previously alive
- **Persistent State**: Remembers last known death status

### 🔔 Notification System
- **Death Alerts**: Push notifications for newly deceased celebrities
- **Configurable**: Users can enable/disable notifications
- **Rich Content**: Includes celebrity name, occupation, and death information

### 🎛️ User Controls
- **Manual Check**: Users can trigger immediate death checks
- **Frequency Settings**: Easy-to-use picker in Settings
- **Last Check Display**: Shows when the last automatic check occurred

## Implementation Details

### Core Components

1. **CronService** (`CronService.swift`)
   - Manages background task scheduling
   - Handles notification permissions
   - Coordinates with DeathCheckService

2. **DeathCheckService** (`DeathCheckService.swift`)
   - Performs actual death checks via Wikipedia/Wikidata
   - Compares current state with last known state
   - Updates celebrity information in the app

3. **NetworkService** (`NetworkService.swift`)
   - Fetches death dates from Wikipedia/Wikidata APIs
   - Handles API requests and data parsing

### Background Task Configuration

The app uses iOS Background App Refresh with the identifier:
```
com.cripiosapp.deathcheck
```

### Data Persistence

- **UserDefaults**: Stores CRON frequency, notification settings, and last check date
- **JSON Encoding**: Stores last known death states for comparison

## Usage

### For Users

1. **Configure Frequency**:
   - Open Settings → Background Death Checks
   - Select desired frequency from the picker
   - Choose "Disabled" to turn off automatic checks

2. **Manual Check**:
   - Tap "Check for Deaths Now" in Settings
   - Wait for the check to complete
   - View results in the Celebrities tab

3. **Notifications**:
   - Enable/disable in Settings → Notifications
   - Receive alerts when new deaths are detected

### For Developers

#### Starting the Service
```swift
// Automatically started in CRIPiOSAppApp.init()
CronService.shared.startCronService()
```

#### Updating Frequency
```swift
CronService.shared.updateFrequency(.daily)
```

#### Manual Death Check
```swift
await CronService.shared.performManualDeathCheck()
```

#### Checking Specific Celebrity
```swift
let deathCheckService = DeathCheckService()
if let updatedCelebrity = await deathCheckService.checkSpecificCelebrity(celebrity) {
    // Celebrity has passed away
}
```

## Configuration

### Background Task Setup

1. **Info.plist**: Add background modes
   ```xml
   <key>UIBackgroundModes</key>
   <array>
       <string>background-app-refresh</string>
   </array>
   ```

2. **BackgroundTasks.plist**: Define task identifiers
   ```xml
   <array>
       <string>com.cripiosapp.deathcheck</string>
   </array>
   ```

### Notification Permissions

The app automatically requests notification permissions on first launch. Users can manage these in iOS Settings.

## API Integration

### Wikipedia/Wikidata APIs

The service uses two main APIs:

1. **Wikipedia API**: For initial celebrity lookup
   ```
   https://en.wikipedia.org/w/api.php?action=query&titles={name}&prop=pageprops&format=json
   ```

2. **Wikidata API**: For death date information
   ```
   https://www.wikidata.org/wiki/Special:EntityData/{wikibase_item}.json
   ```

### Rate Limiting

- Respects API rate limits
- Implements exponential backoff for failed requests
- Caches results to minimize API calls

## Privacy & Performance

### Data Handling
- Only stores necessary information locally
- No personal data transmitted to external services
- Death checks are performed anonymously

### Performance Optimization
- Efficient caching of celebrity data
- Minimal background processing
- Smart comparison to avoid unnecessary API calls

## Troubleshooting

### Common Issues

1. **Background Tasks Not Running**
   - Check iOS Background App Refresh settings
   - Ensure app has background refresh permission
   - Verify task identifier in BackgroundTasks.plist

2. **Notifications Not Working**
   - Check notification permissions in iOS Settings
   - Verify notification settings in app
   - Test with manual death check

3. ** API Errors**
   - Check internet connectivity
   - Verify API endpoints are accessible
   - Review console logs for specific error messages

### Debug Information

Enable debug logging by adding to console:
```
CronService: Background task scheduled successfully
DeathCheckService: Performing death check...
NetworkService: Fetching death date for [celebrity name]
```

## Future Enhancements

- [ ] Multiple data sources for death verification
- [ ] Custom notification sounds
- [ ] Death cause information
- [ ] Historical death tracking
- [ ] Export death statistics
- [ ] Social media integration for death announcements 