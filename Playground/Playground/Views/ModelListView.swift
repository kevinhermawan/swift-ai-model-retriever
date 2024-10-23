//
//  ModelListView.swift
//  Playground
//
//  Created by Kevin Hermawan on 10/14/24.
//

import SwiftUI
import AIModelRetriever

struct ModelListView: View {
    private let title: String
    private let provider: AIProvider
    
    @Environment(AppViewModel.self) private var viewModel
    @State private var models: [AIModel] = []
    
    init(title: String, provider: AIProvider) {
        self.title = title
        self.provider = provider
    }
    
    var body: some View {
        List(models) { model in
            VStack(alignment: .leading) {
                Text(model.id)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                
                Text(model.name)
            }
        }
        .navigationTitle(title)
        .task {
            let retriever = AIModelRetriever()
            
            do {
                switch provider {
                case .anthropic:
                    models = retriever.anthropic()
                case .cohere:
                    models = try await retriever.cohere(apiKey: viewModel.cohereAPIKey)
                case .google:
                    models = retriever.google()
                case .ollama:
                    models = try await retriever.ollama()
                case .openai:
                    models = try await retriever.openAI(apiKey: viewModel.openaiAPIKey)
                case .groq:
                    models = try await retriever.openAI(apiKey: viewModel.groqAPIKey, endpoint: URL(string: "https://api.groq.com/openai/v1/models"))
                }
            } catch {
                print(String(describing: error))
            }
        }
    }
}
