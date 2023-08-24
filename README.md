# Movie Explorer App

Welcome to the Movie Explorer app, built on top of [TMDb](https://www.themoviedb.org/settings/api) API! This app allows you to explore movies and TV shows, view details about them, and discover new content based on genres. Below you'll find information on how to build the app, its general architecture, and the libraries used.

## How to Build the App

1. **Clone the Repository**: Start by cloning this repository to your local machine using `git clone`.

2. **Install Dependencies**: The app uses CocoaPods for managing dependencies. Run `pod install` in the project directory to install the required libraries.

3. **API Key**: To fetch data from The Movie Database (TMDb) API, you'll need an API key. Get your API key from the [TMDb website](https://www.themoviedb.org/settings/api) and add it to the `Constants.swift` file.

4. **Open Xcode**: Open the `.xcworkspace` file using Xcode.

5. **Build and Run**: Build and run the app using Xcode's simulator or on a physical device.

## General Architecture

The app follows a **MVVM (Model-View-ViewModel)** architecture pattern for clean separation of concerns and improved testability.

- **Model**: Represents the data and business logic. Includes the data models and network service for fetching data.

- **View**: Displays the UI elements to the user. Written using SwiftUI for a modern and declarative UI.

- **ViewModel**: Acts as a bridge between the Model and View. Contains presentation logic and data transformation.

## Libraries Used

The app utilizes the following libraries:

- **Alamofire**: A Swift-based HTTP networking library for making API requests.

- **RxSwift and RxCocoa**: Reactive programming libraries that simplify handling asynchronous events and data streams.

- **Kingfisher**: A library for downloading and caching images from the web.

- **CocoaPods**: Dependency manager for Swift and Objective-C projects.

## Feedback and Contributions

Feel free to provide feedback, report issues, or contribute to the project by submitting pull requests. I'll appreciate your help in making the app better!
