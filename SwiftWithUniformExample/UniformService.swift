//
//  UniformService.swift
//  SwiftWithUniformExample
//
//  Created by uniform on 06-11-2025.
//

import Foundation
import Combine

class UniformService: ObservableObject {
    @Published var slides: [CarouselSlideViewModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var debugInfo: DebugInfo?
    @Published var selectedVisitorId: String = "1"
    
    static let visitorIds = ["1", "2", "3"]
    
    func fetchComposition() async {
        await MainActor.run {
            isLoading = true
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
        request.setValue(selectedVisitorId, forHTTPHeaderField: "x-visitor-id")
        
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
            
            let compositionResponse = try JSONDecoder().decode(UniformCompositionResponse.self, from: data)
            
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
            
            // Extract slides from the nested structure
            let carouselSlides = compositionResponse.compositionApiResponse.composition.slots.mainContent
                .first(where: { $0.type == "carousel" })?
                .slots?.slides ?? []
            
            let viewModels = carouselSlides.map { CarouselSlideViewModel(from: $0.parameters) }
            
            await MainActor.run {
                self.slides = viewModels
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
            URLQueryItem(name: "path", value: UniformConfig.path)
        ]
        return components?.url
    }
}

