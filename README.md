# Movie Explorer App

Welcome to the Movie Explorer app, built with **Swift 6** on top of the [TMDb](https://www.themoviedb.org/settings/api) API! This modern iOS application allows you to explore movies and TV shows, search for content, view details, and discover new media based on genres. Built using the latest Swift concurrency features for optimal performance and safety.

## How to Build the App

1. **Clone the Repository**: Start by cloning this repository to your local machine using `git clone`.

2. **Install Dependencies**: The app uses CocoaPods for managing dependencies. Run `pod install` in the project directory to install the required libraries.

3. **API Key Configuration**:
   - To fetch data from The Movie Database (TMDb) API, you'll need an API key
   - Get your API key from the [TMDb website](https://www.themoviedb.org/settings/api)
   - Add it to the `Constants.swift` file (replace `YOUR_TMDB_API_KEY`)

   **⚠️ Security Warning**:
   - Never commit your API key to version control
   - Add `Constants.swift` to `.gitignore` before committing
   - For production apps, use environment variables or secure key storage solutions like Keychain

4. **Open Xcode**: Open the `.xcworkspace` file using Xcode.

5. **Build and Run**: Build and run the app using Xcode's simulator or on a physical device.

## General Architecture

The app follows a **modern MVVM (Model-View-ViewModel)** architecture with a dedicated service layer:

- **Model**: Sendable data models with thread-safe design for Swift 6 concurrency
  - All models conform to `Sendable` protocol
  - Static cached formatters for optimal performance
  - Immutable structs to prevent data races

- **Service Layer**: Actor-based API service using async/await
  - `TMDBAPIService` actor for thread-safe network operations
  - Comprehensive error handling with custom `APIError` types
  - Fully async/await based networking

- **ViewModel**: `@MainActor` annotated view models for safe UI updates
  - Generic `MediaListViewModel` for both movies and TV shows
  - Reactive state management with `@Published` properties
  - Async methods for all network operations

- **View**: Modern SwiftUI views with async/await support
  - Pull-to-refresh functionality
  - Real-time search
  - Loading and error states
  - Infinite scrolling pagination

## Libraries Used

The app utilizes the following libraries:

- **Alamofire**: A Swift-based HTTP networking library for making API requests.

- **Kingfisher**: A library for downloading and caching images from the web.

- **CocoaPods**: Dependency manager for Swift and Objective-C projects.

## Features

### Core Functionality
- **Dual Browse Mode**: Separate tabs for movies and TV shows
- **Genre Filtering**: Browse content by genre with visual genre selector
- **Real-time Search**: Search for movies and TV shows as you type
- **Infinite Scrolling**: Seamless pagination for endless browsing
- **Pull-to-Refresh**: Swipe down to refresh content
- **Detail Views**: View ratings, overviews, and poster images

### User Experience
- **Loading States**: Visual feedback during data fetches
- **Error Handling**: Comprehensive error messages with retry functionality
- **Empty States**: Friendly messages when no content is found
- **Image Caching**: Fast image loading with Kingfisher
- **Smooth Animations**: Polished UI transitions

### Technical Highlights
- **Swift 6 Concurrency**: Full async/await implementation
- **Thread Safety**: `@MainActor` annotations and `Sendable` conformance
- **Data Race Protection**: Compile-time safety guarantees
- **Performance Optimized**: Static cached formatters and lazy loading
- **Clean Architecture**: Separation of concerns with service layer
- **Type-Safe Networking**: Decodable models with error handling

## Feedback and Contributions

Feel free to provide feedback, report issues, or contribute to the project by submitting pull requests. I'll appreciate your help in making the app better!
