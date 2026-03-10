//
//  ContentView.swift
//  SwiftWithUniformExample
//
//  Created by uniform on 06-11-2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var uniformService = UniformService()
    
    var body: some View {
        VStack(spacing: 0) {
            // Visitor switcher
            visitorSwitcher
            
            ZStack {
            if uniformService.isLoading {
                ProgressView("Loading...")
            } else if let errorMessage = uniformService.errorMessage {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text("Error")
                        .font(.headline)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Button("Retry") {
                        Task {
                            await uniformService.fetchComposition()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else if uniformService.slides.isEmpty {
                Text("No slides available")
                    .foregroundColor(.secondary)
            } else {
                ZStack {
                    CarouselView(slides: uniformService.slides)
                    
                    // Debug info overlay
                    if let debugInfo = uniformService.debugInfo {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                DebugInfoView(debugInfo: debugInfo)
                                    .padding()
                            }
                        }
                    }
                }
            }
        }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            await uniformService.fetchComposition()
        }
    }
    
    private var visitorSwitcher: some View {
        HStack(spacing: 12) {
            Text("Visitor:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Picker("Visitor", selection: Binding(
                get: { uniformService.selectedVisitorId },
                set: { newValue in
                    uniformService.selectedVisitorId = newValue
                    Task { await uniformService.fetchComposition() }
                }
            )) {
                ForEach(UniformService.visitorIds, id: \.self) { id in
                    Text("Visitor \(id)").tag(id)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemBackground))
    }
}

// MARK: - Debug Info View

struct DebugInfoView: View {
    let debugInfo: DebugInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Personalization Worker Cache Status: \(formatStringValue(debugInfo.cfCacheStatus))")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.white)

            Text("Personalization Worker Call Time: \(formatValue(debugInfo.uniformServiceCallTimeMs))")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.white)

            Text("Customer Context Cache Status: \(formatStringValue(debugInfo.xVercelCache))")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.white)
            
            Text("Customer Context Call Time: \(formatValue(debugInfo.visitorEndpointTimeMs))")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.white)
            
            Text("Uniform API Call Time: \(formatValue(debugInfo.uniformRouteTimeMs))")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.white)
            
            Text("Uniform API Cache Status: \(formatStringValue(debugInfo.uniformApiCacheStatus))")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.white)

        }
        .padding(8)
        .background(Color.black.opacity(0.7))
        .cornerRadius(8)
    }
    
    private func formatValue(_ value: Double?) -> String {
        if let value = value {
            return String(format: "%.2f", value)
        } else {
            return "missing"
        }
    }
    
    private func formatStringValue(_ value: String?) -> String {
        if let value = value {
            return value
        } else {
            return "missing"
        }
    }
}

#Preview {
    ContentView()
}
