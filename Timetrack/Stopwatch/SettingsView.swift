//
//  SettingsView.swift
//  Stopwatch
//
//  Created by Ethan Lim on 13/6/24.
//

import SwiftUI

enum FontStyle: String, Codable { case sansSerif, monospace }
enum TextBodies: String, Codable { case runningTotal, timeSinceLastLap }

class Settings: Identifiable, ObservableObject {
	let id = UUID()
	
	@Published var fontChoice: FontStyle {
		didSet { saveSettings() }
	}
	@Published var showSecondaryText: Bool {
		didSet { saveSettings() }
	}
	@Published var largerFont: TextBodies {
		didSet { saveSettings() }
	}
	@Published var showMillisecondsAfterHour: Bool {
		didSet { saveSettings() }
	}
	@Published var expandLapsOnLap: Bool {
		didSet { saveSettings() }
	}
    @Published var resetToOneStopwatch: Bool {
        didSet { saveSettings() }
    }
	@Published var alwaysShowResetButton: Bool {
        didSet { saveSettings() }
    }
	
	init(fontChoice: FontStyle, largerFont: TextBodies, showSecondaryText: Bool, showMillisecondsAfterHour: Bool, expandLapsOnLap: Bool, resetToOneStopwatch: Bool, alwaysShowResetButton: Bool) {
		self.fontChoice = fontChoice
		self.showSecondaryText = showSecondaryText
		self.largerFont = largerFont
		self.showMillisecondsAfterHour = showMillisecondsAfterHour
		self.expandLapsOnLap = expandLapsOnLap
        self.resetToOneStopwatch = resetToOneStopwatch
        self.alwaysShowResetButton = alwaysShowResetButton
		loadSettings()
	}
	
	private func saveSettings() {
		do {
			let settings = SettingsData(fontChoice: fontChoice, largerFont: largerFont, showMillisecondsAfterHour: showMillisecondsAfterHour, showSecondaryText: showSecondaryText, expandLapsOnLap: expandLapsOnLap, resetToOneStopwatch: resetToOneStopwatch, alwaysShowResetButton: alwaysShowResetButton)
			let data = try JSONEncoder().encode(settings)
			UserDefaults.standard.set(data, forKey: "userSettings")
		} catch {
			print("Failed to save settings: \(error)")
		}
	}
	
	private func loadSettings() {
		guard let data = UserDefaults.standard.data(forKey: "userSettings") else { return }
		do {
			let settings = try JSONDecoder().decode(SettingsData.self, from: data)
			self.fontChoice = settings.fontChoice
			self.showSecondaryText = settings.showSecondaryText
			self.largerFont = settings.largerFont
			self.showMillisecondsAfterHour = settings.showMillisecondsAfterHour
			self.expandLapsOnLap = settings.expandLapsOnLap
            self.resetToOneStopwatch = settings.resetToOneStopwatch
            self.alwaysShowResetButton = settings.alwaysShowResetButton
		} catch {
			print("Failed to load settings: \(error)")
		}
	}
	
	private struct SettingsData: Codable {
		let fontChoice: FontStyle
		let largerFont: TextBodies
		let showMillisecondsAfterHour: Bool
		let showSecondaryText: Bool
		let expandLapsOnLap: Bool
        let resetToOneStopwatch: Bool
        let alwaysShowResetButton: Bool
	}
}



struct SettingsView: View {
	
	// Please arrange settings parameters (variables) in same order as in form
	@EnvironmentObject var settingsConfiguration: Settings
	
	var body: some View {
		NavigationStack {
			Form {
                Section(header: Text("General")) {
                    Picker("Font", selection: $settingsConfiguration.fontChoice) {
                        Text("Sans Serif")
                            .tag(FontStyle.sansSerif)
                        Text("Monospaced")
                            .tag(FontStyle.monospace)
                    }
                }
                Section(header: Text("Stopwatch Settings")) {
                    Toggle("Show secondary text in stopwatch", isOn: $settingsConfiguration.showSecondaryText)
                    Picker("Larger text in stopwatch shows", selection: $settingsConfiguration.largerFont) {
                        Text("Running total")
                            .tag(TextBodies.runningTotal)
                        Text("Time since last lap")
                            .tag(TextBodies.timeSinceLastLap)
                    }
                    Toggle("Show milliseconds after one hour", isOn: $settingsConfiguration.showMillisecondsAfterHour)
                    Toggle("Expand laps panel upon lap", isOn: $settingsConfiguration.expandLapsOnLap)
                    Toggle("Clearing stopwatches leaves one stopwatch", isOn: $settingsConfiguration.resetToOneStopwatch)
                    Toggle("Always show reset stopwatch button", isOn: $settingsConfiguration.alwaysShowResetButton)
                }
			}
			.navigationTitle("Settings")
			.navigationBarTitleDisplayMode(.inline)
		}
	}
}


#Preview {
	SettingsView()
}
