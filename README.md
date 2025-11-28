# JobAppTracker - macOS Application

A beautiful, native macOS app built with SwiftUI to help you track your job applications.

## Features

- **Multiple View Modes**:
  - **List View**: Classic list with search, filters, and statistics
  - **Kanban Board**: Drag-and-drop cards between status columns
- **Timeline Tracking**: Visual timeline showing status changes with dates and notes
- **Track Job Applications**: Keep all your job applications organized in one place
- **Status Management**: Track applications through different stages (Applied, Interviewing, Offer, Rejected, Accepted)
- **Drag & Drop**: Easily move jobs between statuses in Kanban view
- **Search & Filter**: Quickly find jobs by company name, position, or status
- **Detailed Information**: Store company, position, location, salary range, contact information, and notes
- **Status History**: Automatically track when status changes occur with optional notes
- **Statistics Dashboard**: View quick stats on your application progress
- **Data Persistence**: All data is saved automatically and persists between app launches
- **Clean UI**: Modern, native macOS interface with split-view design

## Building the App

### Requirements
- macOS 14.0 or later
- Xcode 15.0 or later

### Build Instructions

1. Open the project in Xcode:
   - Double-click `JobAppTracker.xcodeproj` to open in Xcode
   - Or run: `open JobAppTracker.xcodeproj` from Terminal

2. Select your development team (optional for local builds):
   - Click on the project in the navigator
   - Select the "JobAppTracker" target
   - Go to "Signing & Capabilities"
   - Select your team or choose "Sign to Run Locally"

3. Build and run:
   - Press ⌘R or click the Run button
   - The app will build and launch

### Alternative: Build from Command Line

```bash
# Build the project
xcodebuild -project JobAppTracker.xcodeproj -scheme JobAppTracker -configuration Release build

# The built app will be in:
# build/Release/JobAppTracker.app
```

## How to Use

### Switching Views
Use the segmented control in the top bar to switch between:
- **List View**: Traditional list with filters and search
- **Kanban Board**: Visual board with drag-and-drop functionality

### Adding a Job
1. Click the "+ Add Job" button (available in both views)
2. Fill in the job details:
   - Company name (required)
   - Position title (required)
   - Location
   - Salary range
   - Status
   - Date applied
   - Contact email
   - Notes
3. Click "Save"

### Using the Kanban Board
1. Switch to Kanban view using the view selector
2. See jobs organized by status in columns
3. Drag any job card to a different column to update its status
4. Click on any card to view full details
5. Status changes are automatically tracked in the timeline

### Viewing Job Details & Timeline
1. In List view, click on any job to view details in the right panel
2. Switch between "Details" and "Timeline" tabs:
   - **Details**: Shows all job information with edit button
   - **Timeline**: Shows chronological history of status changes
3. Each timeline entry shows:
   - Status change icon and color
   - Date and time of change
   - Any notes added during the status update
   - Days spent in current status

### Editing a Job
1. Select a job from the list
2. Click the "Edit" button in the detail view
3. Make your changes
4. If you change the status, you can add a note explaining the change
5. Click "Save" - status changes are automatically recorded in timeline

### Filtering Jobs (List View)
- Use the search bar to find jobs by company or position name
- Click on status chips (Applied, Interviewing, Offer, Rejected, Accepted) to filter by status
- Click "All" to clear filters

### Deleting a Job
1. Select a job from the list
2. Click "Edit"
3. Scroll down and click "Delete Job"
   
Or swipe left on a job in the list and click Delete

## Data Storage

All job data is stored locally on your Mac using UserDefaults. Your data persists between app launches and is private to your device.

## Project Structure

```
JobAppTracker/
├── JobAppTrackerApp.swift      # App entry point
├── ContentView.swift        # Main view with list mode and view switcher
├── KanbanBoardView.swift    # Kanban board with drag-and-drop
├── TimelineView.swift       # Timeline visualization of status changes
├── Job.swift                # Job data model with status history
├── JobStore.swift           # Data management and persistence
├── AddJobView.swift         # New job creation form
├── JobDetailView.swift      # Job detail display
└── EditJobView.swift        # Job editing form with status change tracking
```

## Customization

The app uses native macOS design patterns and can be easily customized:

- **Colors**: Modify status colors in `Job.swift`
- **Fields**: Add new fields to the `Job` struct and update the forms
- **Filters**: Add custom filters in `ContentView.swift`
- **Storage**: Replace UserDefaults with Core Data or file-based storage in `JobStore.swift`

## License

Free to use and modify for personal use.
