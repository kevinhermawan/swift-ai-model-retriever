//
//  AppViewModel.swift
//  Playground
//
//  Created by Kevin Hermawan on 10/14/24.
//

import Foundation

@Observable
final class AppViewModel {
    var openaiAPIKey: String
    var groqAPIKey: String
    
    init() {
        self.openaiAPIKey = UserDefaults.standard.string(forKey: "openaiAPIKey") ?? ""
        self.groqAPIKey = UserDefaults.standard.string(forKey: "groqAPIKey") ?? ""
    }
    
    func saveAPIKeys() {
        UserDefaults.standard.set(openaiAPIKey, forKey: "openaiAPIKey")
        UserDefaults.standard.set(groqAPIKey, forKey: "groqAPIKey")
    }
}
