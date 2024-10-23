//
//  AppView.swift
//  Playground
//
//  Created by Kevin Hermawan on 10/14/24.
//

import SwiftUI

enum AIProvider: String, CaseIterable {
    case anthropic = "Anthropic"
    case cohere = "Cohere"
    case google = "Google"
    case ollama = "Ollama"
    case openai = "OpenAI"
    case groq = "OpenAI-Compatible (Groq)"
}

struct AppView: View {
    @Environment(AppViewModel.self) private var viewModel
    @State private var isSettingsPresented: Bool = false
    
    var body: some View {
        NavigationStack {
            List(AIProvider.allCases, id: \.rawValue) { provider in
                NavigationLink(provider.rawValue) {
                    ModelListView(title: provider.rawValue, provider: provider)
                }
                .disabled(provider == .cohere && viewModel.cohereAPIKey.isEmpty)
                .disabled(provider == .groq && viewModel.groqAPIKey.isEmpty)
                .disabled(provider == .openai && viewModel.openaiAPIKey.isEmpty)
            }
            .navigationTitle("Playground")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Settings", systemImage: "gearshape") {
                        isSettingsPresented = true
                    }
                }
            }
            .sheet(isPresented: $isSettingsPresented) {
                SettingsView()
            }
        }
    }
}
