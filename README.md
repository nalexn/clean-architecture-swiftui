# Clean Architecture for SwiftUI + Combine

A demo project showcasing the setup of the SwiftUI app with Clean Architecture.

The app uses the [restcountries.eu](restcountries.eu) REST API to show the list of countries and details about them.

## Key features
* Designed for scalability. It can be used as a reference for building large production apps.
* Vanilla **SwiftUI** + **Combine** implementation. No 3rd party dependencies
* Programmatic navigation (deep links support)
* Decoupled **Presentation**, **Business Logic**, and **Data Access** layers
* Everything is a `Struct` (except for a couple of modules)
* Centralized `AppState` as a **single source of truth**
* Dependency injection of `Interactors` and `AppState`
* Simple yet flexible networking layer built on Generics
* Handling of system events (such as `didBecomeActive`, `willResignActive`)
* Built with SOLID, DRY, KISS, YAGNI in mind.

## Architecture overview

<p align="center">
  <img src="https://github.com/nalexn/blob_files/blob/master/images/swiftui_arc_001.png?raw=true" alt="Diagram"/>
</p>

### Presentation Layer

**SwiftUI views** that contain no business logic and are a function of the state.
`AppState` is injected into the view hierarchy as `@EnvironmentObject`

Side effects are triggered by the user's actions (such as a tap on a button) or view lifecycle event `onAppear` and are forwarded to the business logic layer.

### Business Logic Layer

Business Logic layer is represented by `Interactors`. 

Interactors receive requests to perform work, such as obtaining data from an external source or making computations, but they never return data back directly.

Instead, they forward the result to the `AppState` or to a `Binding`. The latter is used when the result of work (the data) is used locally by one View and does not belong to the `AppState`

Interactors are injected into the view hierarchy within a container as an `@Environment` variable.

### Data Access Layer

Data Access layer is represented by `Repositories`.

Repositories provide asynchronous API (`Publisher` from Combine) for making [CRUD](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete) operations on the backend or a local database. They don't contain business logic, neither do they mutate the `AppState`. Repositories are accessible and used only by the Interactors.

---

This is a work-in-progress repository. ToDo:

* Local database
* 99% test coverage
* REDUX state management

### License
MIT
