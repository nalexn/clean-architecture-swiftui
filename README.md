### Articles related to this project

* [Clean Architecture for SwiftUI](https://nalexn.github.io/clean-architecture-swiftui/?utm_source=nalexn_github)
* [Programmatic navigation in SwiftUI project](https://nalexn.github.io/swiftui-deep-linking/?utm_source=nalexn_github)
* [Why I quit using the ObservableObject in SwiftUI](https://nalexn.github.io/swiftui-observableobject/?utm_source=nalexn_github)

---

# Clean Architecture for SwiftUI + Combine

A demo project showcasing the setup of the SwiftUI app with Clean Architecture.

The app uses the [restcountries.eu](restcountries.eu) REST API to show the list of countries and details about them.

![platforms](https://img.shields.io/badge/platforms-iPhone%20%7C%20iPad%20%7C%20macOS-lightgrey) [![Build Status](https://travis-ci.com/nalexn/clean-architecture-swiftui.svg?branch=master)](https://travis-ci.com/nalexn/clean-architecture-swiftui) [![codecov](https://codecov.io/gh/nalexn/clean-architecture-swiftui/branch/master/graph/badge.svg)](https://codecov.io/gh/nalexn/clean-architecture-swiftui) [![codebeat badge](https://codebeat.co/badges/db33561b-0b2b-4ee1-a941-a08efbd0ebd7)](https://codebeat.co/projects/github-com-nalexn-clean-architecture-swiftui-master) [![Beerpay](https://beerpay.io/nalexn/clean-architecture-swiftui/badge.svg?style=beer)](https://beerpay.io/nalexn/clean-architecture-swiftui)

<p align="center">
  <img src="https://github.com/nalexn/blob_files/blob/master/images/countries_preview.png?raw=true" alt="Diagram"/>
</p>

## Key features
* Designed for **scalability**. It can be used as a reference for building large production apps.
* Vanilla **SwiftUI** + **Combine** implementation. No 3rd party dependencies
* **Programmatic navigation** (deep links support)
* Decoupled **Presentation**, **Business Logic**, and **Data Access** layers
* Everything is a `Struct` (except for a couple of modules)
* Centralized `AppState` as a **single source of truth**
* Dependency injection of `Interactors` and `AppState`
* Simple yet flexible **networking layer** built on Generics
* Handling of system events (such as `didBecomeActive`, `willResignActive`)
* Built with SOLID, DRY, KISS, YAGNI in mind.

## Architecture overview

<p align="center">
  <img src="https://github.com/nalexn/blob_files/blob/master/images/swiftui_arc_001.png?raw=true" alt="Diagram"/>
</p>

### Presentation Layer

**SwiftUI views** that contain no business logic and are a function of the state.

Side effects are triggered by the user's actions (such as a tap on a button) or view lifecycle event `onAppear` and are forwarded to the `Interactors`.

State and business logic layer (`AppState` + `Interactors`) are navitely injected into the view hierarchy with `@Environment`.

### Business Logic Layer

Business Logic Layer is represented by `Interactors`. 

Interactors receive requests to perform work, such as obtaining data from an external source or making computations, but they never return data back directly.

Instead, they forward the result to the `AppState` or to a `Binding`. The latter is used when the result of work (the data) is used locally by one View and does not belong to the `AppState`.

### Data Access Layer

Data Access Layer is represented by `Repositories`.

Repositories provide asynchronous API (`Publisher` from Combine) for making [CRUD](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete) operations on the backend or a local database. They don't contain business logic, neither do they mutate the `AppState`. Repositories are accessible and used only by the Interactors.

---

![license](https://img.shields.io/badge/license-mit-brightgreen) [![Twitter](https://img.shields.io/badge/twitter-nallexn-blue)](https://twitter.com/nallexn) [![blog](https://img.shields.io/badge/blog-medium-red)](https://medium.com/@nalexn)
