//
//  SettingsView.swift
//  Playground
//
//  Created by Kevin Hermawan on 10/14/24.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var viewModel
    
    var body: some View {
        @Bindable var viewModelBindable: AppViewModel = viewModel
        
        NavigationStack {
            Form {
                Section("OpenAI API Key") {
                    TextField("API Key", text: $viewModelBindable.openaiAPIKey)
                }
                
                Section("Groq API Key (OpenAI-compatible)") {
                    TextField("API Key", text: $viewModelBindable.groqAPIKey)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: { dismiss() })
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.saveAPIKeys()
                        dismiss()
                    }
                    .disabled(viewModel.openaiAPIKey.isEmpty && viewModel.groqAPIKey.isEmpty)
                }
            }
        }
    }
}
