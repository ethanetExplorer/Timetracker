//
//  TimerKeyboard.swift
//  Stopwatch
//
//  Created by Ethan Lim on 15/8/24.
//

import Foundation
import SwiftUI
import CustomKeyboardKit

extension CustomKeyboard {
	
    static var timerInputBoard: CustomKeyboard {
        CustomKeyboardBuilder { textDocumentProxy, submit, playSystemFeedback in
            VStack {
				HStack {
					Button {
						textDocumentProxy.insertText("h")
						playSystemFeedback?()
					} label: {
						Text("h")
							.foregroundStyle(.accent)
							.font(.title3)
							.frame(maxWidth: .infinity)
					}
					Button {
						textDocumentProxy.insertText("m")
						playSystemFeedback?()
					} label: {
						Text("m")
							.foregroundStyle(.accent)
							.font(.title3)
							.frame(maxWidth: .infinity)
					}
					Button {
						textDocumentProxy.insertText("s")
						playSystemFeedback?()
					} label: {
						Text("s")
							.foregroundStyle(.accent)
							.font(.title3)
							.frame(maxWidth: .infinity)
					}
				}
				HStack {
					Button {
						textDocumentProxy.insertText("7")
						playSystemFeedback?()
					} label: {
						Text("7")
							.font(.title2)
							.frame(maxWidth: .infinity)
					}
					Button {
						textDocumentProxy.insertText("8")
						playSystemFeedback?()
					} label: {
						Text("8")
							.font(.title2)
							.frame(maxWidth: .infinity)
					}
					Button {
						textDocumentProxy.insertText("9")
						playSystemFeedback?()
					} label: {
						Text("9")
							.font(.title2)
							.frame(maxWidth: .infinity)
					}
				}
				HStack {
					Button {
						textDocumentProxy.insertText("4")
						playSystemFeedback?()
					} label: {
						Text("4")
							.font(.title2)
							.frame(maxWidth: .infinity)
					}
					Button {
						textDocumentProxy.insertText("5")
						playSystemFeedback?()
					} label: {
						Text("5")
							.font(.title2)
							.frame(maxWidth: .infinity)
					}
					Button {
						textDocumentProxy.insertText("6")
						playSystemFeedback?()
					} label: {
						Text("6")
							.font(.title2)
							.frame(maxWidth: .infinity)
					}
				}
				HStack {
					Button {
						textDocumentProxy.insertText("1")
						playSystemFeedback?()
					} label: {
						Text("1")
							.font(.title2)
							.frame(maxWidth: .infinity)
					}
					Button {
						textDocumentProxy.insertText("2")
						playSystemFeedback?()
					} label: {
						Text("2")
							.font(.title2)
							.frame(maxWidth: .infinity)
					}
					Button {
						textDocumentProxy.insertText("3")
						playSystemFeedback?()
					} label: {
						Text("3")
							.font(.title2)
							.frame(maxWidth: .infinity)
					}
				}
				HStack {
					Button {
						textDocumentProxy.insertText(":")
						playSystemFeedback?()
					} label: {
						Text(":")
							.font(.title2)
							.frame(maxWidth: .infinity)
					}
					Button {
						textDocumentProxy.insertText("0")
						playSystemFeedback?()
					} label: {
						Text("0")
							.font(.title2)
							.frame(maxWidth: .infinity)
					}
					Button {
						textDocumentProxy.deleteBackward()
						playSystemFeedback?()
					} label: {
						Image(systemName: "delete.backward")
							.font(.title2)
							.frame(maxWidth: .infinity)
							.foregroundStyle(.red)
					}
					.buttonRepeatBehavior(.enabled)
				}
				Button {
					submit()
				} label: {
					Text("Done")
						.frame(maxWidth: .infinity)
				}
            }
			.foregroundStyle(Color("TextColor"))
            .buttonStyle(.bordered)
            .padding()
        }
    }
}
