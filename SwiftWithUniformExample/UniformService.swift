//
//  UniformService.swift
//  SwiftWithUniformExample
//
//  Created by uniform on 06-11-2025.
//

import Foundation
import Combine

class UniformService: ObservableObject {
    @Published var contentItems: [MainContentItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var debugInfo: DebugInfo?
    @Published var selectedVisitorId: String = "1"
    
    let visitorProfiles = VisitorProfile.allProfiles
    
    var selectedProfile: VisitorProfile? {
        visitorProfiles.first(where: { $0.id == selectedVisitorId })
    }
    
    func fetchComposition() async {
        let isFirstLoad = await MainActor.run { contentItems.isEmpty }
        await MainActor.run {
            if isFirstLoad { isLoading = true }
            errorMessage = nil
        }
        
        guard let url = buildURL() else {
            await MainActor.run {
                isLoading = false
                errorMessage = "Invalid URL"
            }
            return
        }
        
        var request = URLRequest(url: url)
        // This is to ensure that the data is not cachedn inside app's cache. Optional.
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.httpMethod = "GET"
        request.setValue(UniformConfig.apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue(selectedVisitorId, forHTTPHeaderField: "visitor-id")
        // request.setValue("leisure", forHTTPHeaderField: "audience")
        // request.setValue("local", forHTTPHeaderField: "geoAudience")
        // request.setValue("true", forHTTPHeaderField: "hasReservation")
        
        do {
            // Track HTTP request timing
            let startTime = Date()
            let (data, response) = try await URLSession.shared.data(for: request)
            let requestTimeMs = Date().timeIntervalSince(startTime) * 1000.0
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to fetch data"
                }
                return
            }
            
            // Check for error/notFound responses before full decoding
            if let rawResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let type = rawResponse["type"] as? String,
               type == "notFound" {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Route not found. Check that the path '\(UniformConfig.path)' exists and is published in your Uniform project."
                }
                return
            }
            
            let compositionResponse: UniformCompositionResponse
            do {
                compositionResponse = try JSONDecoder().decode(UniformCompositionResponse.self, from: data)
            } catch let decodingError as DecodingError {
                let detail: String
                switch decodingError {
                case .keyNotFound(let key, let context):
                    detail = "Missing key '\(key.stringValue)' at \(context.codingPath.map(\.stringValue).joined(separator: "."))"
                case .typeMismatch(let type, let context):
                    detail = "Type mismatch for \(type) at \(context.codingPath.map(\.stringValue).joined(separator: "."))"
                case .valueNotFound(let type, let context):
                    detail = "Null value for \(type) at \(context.codingPath.map(\.stringValue).joined(separator: "."))"
                default:
                    detail = decodingError.localizedDescription
                }
                print("[alex] Decoding error: \(detail)")
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Decoding error: \(detail)"
                }
                return
            }
            
            // Extract debug info from response and HTTP headers
            let httpCfCacheStatus = httpResponse.value(forHTTPHeaderField: "Cf-Cache-Status")
            
            // Extract debug info from JSON response debug section
            let debug = compositionResponse.debug
            print("[Uniform] Full debug reply:")
            dump(compositionResponse)

            let debugInfo = DebugInfo(
                uniformServiceCallTimeMs: requestTimeMs,
                visitorEndpointTimeMs: debug?.visitorEndpointTimeMs,
                uniformRouteTimeMs: debug?.uniformRouteTimeMs,
                processCompositionTimeMs: debug?.processCompositionTimeMs,
                xVercelCache: debug?.xVercelCache,
                cfCacheStatus: httpCfCacheStatus,
                uniformApiCacheStatus: debug?.cfCacheStatus
            )
            
            let mainContent = compositionResponse.compositionApiResponse.composition.slots.mainContent
            
            let carouselSlides = mainContent
                .first(where: { $0.type == "carousel" })?
                .slots?.slides ?? []
            let slideViewModels = carouselSlides.map { CarouselSlideViewModel(from: $0.parameters) }
            
            await MainActor.run {
                self.contentItems = mainContent.compactMap {
                    ComponentRegistry.mapComponent($0, slides: slideViewModels, profile: self.selectedProfile)
                }
                self.debugInfo = debugInfo
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = "Error: \(error.localizedDescription)"
            }
        }
    }
    
    private func buildURL() -> URL? {
        var components = URLComponents(string: UniformConfig.baseURL)
        components?.queryItems = [
            URLQueryItem(name: "projectId", value: UniformConfig.projectId),
            URLQueryItem(name: "path", value: UniformConfig.path),
            URLQueryItem(name: "state", value: "0")
        ]
        return components?.url
    }
}

