import SwiftUI

@main
struct AES_128_GUIApp: App {
    var body: some Scene {
           Window("AES-128 GUI", id: "main") {
               ContentView()
                   .frame(
                       minWidth: 400, idealWidth: 400, maxWidth: 400,
                       minHeight: 250, idealHeight: 250, maxHeight: 250
                   )
           }
           .windowResizability(.contentSize)
       }
}
