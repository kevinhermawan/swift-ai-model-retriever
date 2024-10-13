//
//  PlaygroundApp.swift
//  Playground
//
//  Created by Kevin Hermawan on 10/14/24.
//

import SwiftUI

@main
struct PlaygroundApp: App {
    @State private var viewModel = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(viewModel)
        }
    }
}
