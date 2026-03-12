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
            topBar
            
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
            } else if uniformService.contentItems.isEmpty {
                Text("No content available")
                    .foregroundColor(.secondary)
            } else {
                ZStack(alignment: .bottomTrailing) {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(uniformService.contentItems) { item in
                                ComponentRegistry.view(for: item)
                            }
                        }
                    }
                    
                    if let profile = uniformService.selectedProfile {
                        VisitorProfileInfoView(profile: profile)
                            .padding()
                    }
                }
            }
        }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            await uniformService.fetchComposition()
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                await uniformService.fetchComposition()
            }
        }
    }
    
    private var topBar: some View {
        ZStack {
            Image("Logo")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(height: 24)
                .foregroundColor(.primary)
            
            HStack {
                Spacer()
                
                Menu {
                    ForEach(uniformService.visitorProfiles) { profile in
                        Button {
                            uniformService.selectedVisitorId = profile.id
                            Task { await uniformService.fetchComposition() }
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(profile.name)
                                    Text("\(profile.audience) · \(profile.geoProximity) · \(profile.membershipStatus)")
                                        .font(.caption)
                                }
                                if uniformService.selectedVisitorId == profile.id {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        if let profile = uniformService.selectedProfile {
                            Text(profile.name.components(separatedBy: " ").first ?? profile.name)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                        Image(systemName: "person.crop.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white, Color.accentColor)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
    }
}

// MARK: - Visitor Profile Info View

struct VisitorProfileInfoView: View {
    let profile: VisitorProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Text(profile.name)
                    .font(.system(.caption, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
                Text(profile.membershipStatus)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(profile.membershipStatus == "member" ? .green : .gray)
            }
            
            Divider().background(Color.white.opacity(0.3))
            
            infoRow("Audience", profile.audience)
            infoRow("Geo", "\(profile.geoProximity) · \(profile.zipCode)")
            
            if let reservation = profile.reservation {
                Divider().background(Color.white.opacity(0.3))
                infoRow("Hotel", reservation.hotelName)
                infoRow("Dates", "\(reservation.checkIn) → \(reservation.checkOut)")
                Text(reservation.confirmationNumber)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(.white.opacity(0.5))
            } else {
                Text("No reservation")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.top, 2)
            }
        }
        .padding(10)
        .background(Color.black.opacity(0.7))
        .cornerRadius(8)
        .frame(maxWidth: 260)
    }
    
    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack(spacing: 4) {
            Text("\(label):")
                .foregroundColor(.white.opacity(0.7))
            Text(value)
                .foregroundColor(.white)
        }
        .font(.system(.caption, design: .monospaced))
    }
}

#Preview {
    ContentView()
}
