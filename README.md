# Swifty Alert

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fchocoford%2FSwiftyAlert%2Fbadge%3Ftype%3Dswift-versions) ](https://swiftpackageindex.com/chocoford/SwiftyAlert) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fchocoford%2FSwiftyAlert%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/chocoford/SwiftyAlert) ![GitHub License](https://img.shields.io/github/license/chocoford/SwiftyAlert) ![X (formerly Twitter) Follow](https://img.shields.io/twitter/follow/dove_zachary?label=Chocoford)

`SwiftyAlert` is a lightweight, multiplatform, easy-to-use `swiftUI` package that for errors handling. Integrated with `SwiftUI Environment`.



## Platforms

* macOS 12.0+
* iOS 15.0+
* macCatalyst 15.0+
* tvOS 15.0+
* watchOS 8.0+
* visionOS 1.0+



## Installation

In an app project or framework, in Xcode:

* Select the menu: **File → Swift Packages → Add Package Dependency...**

* Enter this URL: `https://github.com/chocoford/SwiftyAlert`

---

Or in a Swift Package, add it to the Package.swift dependencies:

```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/chocoford/SwiftyAlert.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            ...
            dependencies: [
                ...
                "SwiftyAlert"
            ],
            ...
        )
    ]
)
```



## Usage

#### Import package

```swift
import SwiftyAlert
```



#### Inject environments somewhere first

for example, you can inject environments directly in `YourApp.swift`

```swift
@main
struct YourApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .swiftyAlert() // <-- inject environments here.
        }
    }
}
```



#### Use with @Environment

```swift

struct ContentView: View {
  @Environment(\.alert) private var alert // <-- use with @Environment
  
  var body: some View {
	Button {
          alert(title: "Alert") {
              Button {
                  ...
              } label: {
                  Text("Alert action")
              }
          } message: {}
          
          // or just use with error
          do {...} catch {
             alert(error)
          }
          
        } label: {
          Text("Alert")
        }
    }
}
```



#### Use with AlertToast

Also if your project has imported [`AlertToast`](https://github.com/elai950/AlertToast.git), you can use `alertToast` in the same way!

```swift
import AlertToast
import SwiftyAlert

struct ContentView: View {
  @Environment(\.alertToast) private var alertToast

  var body: some View {
    Button {
      do {...} catch {
        alertToast(error) 
      }
    } label: {
      Text("Toggle alertToast")
    }
  }
}
```



#### Use with AlertToast and `.sheet` or `.fullscreenCover`

You can additionally apply `.swiftyAlert(...)` to make alertToast displayed in `sheet` or `fullscreenCover`.

```swift
...
.sheet(isPresented: $showSheet) {
    SheetView()
        .swiftyAlert() // <-- inject for sheet view to display alertToast
}
```





## Trouble shooting

* `Undefined symbols:...` 
  Just `Reset Package Caches` and build again. The problem will be gone.



## Acknowledgment

[elai950 - AlertToast: Create Apple-like alerts & toasts using SwiftUI](https://github.com/elai950/AlertToast)
