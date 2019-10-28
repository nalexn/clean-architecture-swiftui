# Clean Architecture for SwiftUI + Combine

A demo project showcasing the setup of the SwiftUI app with Clean Architecture.

The app uses the [restcountries.eu](restcountries.eu) REST API to show the list of countries and details about them.

## Key features
* Designed for scalability. Can be used as a reference for building production apps.
* Vanilla **SwiftUI** + **Combine** implementation. No 3rd party dependencies
* Programmatic navigation (deep links support)
* Decoupled **Presentation**, **Business Logic** and **Data Access** layers
* Everything is a `Struct` (except for a couple modules)
* Centralized `AppState` as a **single sourse of truth**
* Dependency injection of `Services` and `AppState`
* Simple yet flexible networking layer built on Generics
* Handling of system events (such as `didBecomeActive`, `willResignActive`)
* Built with SOLID, DRY, KISS, YAGNI, (name more) in mind.


---

This is a work-in-progress repository. ToDo:
* 99% test coverege
* REDUX state management (in a separate branch)

### License
MIT
