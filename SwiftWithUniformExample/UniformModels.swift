//
//  UniformModels.swift
//  SwiftWithUniformExample
//
//  Created by uniform on 06-11-2025.
//

import Foundation

// MARK: - API Response Models

struct UniformCompositionResponse: Codable {
    let type: String
    let matchedRoute: String
    let compositionApiResponse: CompositionApiResponse
    let debug: DebugResponse?
}

struct DebugResponse: Codable {
    let visitorEndpointTimeMs: Double?
    let uniformRouteTimeMs: Double?
    let processCompositionTimeMs: Double?
    let xVercelCache: String?
    let cfCacheStatus: String?
    
    enum CodingKeys: String, CodingKey {
        case visitorEndpointTimeMs
        case uniformRouteTimeMs
        case processCompositionTimeMs
        case xVercelCache = "x-vercel-cache"
        case cfCacheStatus = "Cf-Cache-Status"
    }
}

struct CompositionApiResponse: Codable {
    let composition: Composition
}

struct Composition: Codable {
    let slots: Slots
}

struct Slots: Codable {
    let mainContent: [SlotComponent]
}

struct SlotComponent: Codable {
    let type: String
    let slots: CarouselSlots?
    let parameters: ComponentParameters?
}

struct CarouselSlots: Codable {
    let slides: [CarouselSlideComponent]
}

struct CarouselSlideComponent: Codable {
    let type: String
    let parameters: CarouselSlideParameters
}

struct ComponentParameters: Codable {
    let title: ParameterValue?
    let backgroundColor: ParameterValue?
    let checkInLabel: ParameterValue?
    let checkOutLabel: ParameterValue?
    let description: ParameterValue?
    let ctaText: ParameterValue?
    let ctaLink: LinkParameterValue?
    let image: AssetParameterValue?
}

struct CarouselSlideParameters: Codable {
    let title: ParameterValue
    let description: ParameterValue
    let ctaText: ParameterValue
    let ctaLink: LinkParameterValue
    let backgroundColor: ParameterValue
    let titleColor: ParameterValue
    let descriptionColor: ParameterValue
    let ctaBackgroundColor: ParameterValue
    let ctaTextColor: ParameterValue
    let imageName: ParameterValue?
}

struct ParameterValue: Codable {
    let type: String
    let value: String?
}

struct LinkValue: Codable {
    let path: String?
    let type: String?
}

struct LinkParameterValue: Codable {
    let type: String
    let value: LinkValue
}

struct AssetParameterValue: Codable {
    let type: String
    let value: [AssetItem]?
    
    var firstImageUrl: String? {
        guard let item = value?.first else { return nil }
        guard var url = item.url ?? item.fields?.url?.value else { return nil }
        if url.hasPrefix("//") { url = "https:" + url }
        return url
    }
}

struct AssetItem: Codable {
    let url: String?
    let fields: AssetItemFields?
    
    struct AssetItemFields: Codable {
        let url: ParameterValue?
    }
}

// MARK: - View Models

struct CarouselSlideViewModel {
    let title: String
    let description: String
    let ctaText: String
    let ctaUrl: String
    let backgroundColor: String
    let titleColor: String
    let descriptionColor: String
    let ctaBackgroundColor: String
    let ctaTextColor: String
    let imageName: String?
}

extension CarouselSlideViewModel {
    init(from parameters: CarouselSlideParameters) {
        self.title = parameters.title.value ?? ""
        self.description = parameters.description.value ?? ""
        self.ctaText = parameters.ctaText.value ?? ""
        self.ctaUrl = parameters.ctaLink.value.path ?? ""
        self.backgroundColor = parameters.backgroundColor.value ?? "000000"
        self.titleColor = parameters.titleColor.value ?? "FFFFFF"
        self.descriptionColor = parameters.descriptionColor.value ?? "FFFFFF"
        self.ctaBackgroundColor = parameters.ctaBackgroundColor.value ?? "FFFFFF"
        self.ctaTextColor = parameters.ctaTextColor.value ?? "000000"
        self.imageName = parameters.imageName?.value
    }
}

// MARK: - Content Items (order-preserving from API response)

enum MainContentItem: Identifiable {
    case carousel([CarouselSlideViewModel])
    case upcomingReservation(UpcomingReservationViewModel)
    case promotion(PromotionViewModel)
    
    var id: String {
        switch self {
        case .carousel: return "carousel"
        case .upcomingReservation: return "upcomingReservation"
        case .promotion: return "promotion"
        }
    }
}

struct PromotionViewModel {
    let title: String
    let description: String
    let ctaText: String
    let ctaUrl: String?
    let imageUrl: String?
}

struct UpcomingReservationViewModel {
    let title: String
    let checkInLabel: String
    let checkOutLabel: String
    let reservation: ReservationViewModel?
}

// MARK: - Reservation View Model

struct ReservationViewModel {
    let hotelName: String
    let checkInDate: String
    let checkOutDate: String
    let confirmationNumber: String
    let nightCount: Int
    
    var formattedCheckIn: String { Self.formatDate(checkInDate) }
    var formattedCheckOut: String { Self.formatDate(checkOutDate) }
    
    init?(from reservation: VisitorReservation?) {
        guard let reservation = reservation else { return nil }
        self.hotelName = reservation.hotelName
        self.checkInDate = reservation.checkIn
        self.checkOutDate = reservation.checkOut
        self.confirmationNumber = reservation.confirmationNumber
        
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        if let start = fmt.date(from: reservation.checkIn),
           let end = fmt.date(from: reservation.checkOut),
           let days = Calendar.current.dateComponents([.day], from: start, to: end).day {
            self.nightCount = days
        } else {
            self.nightCount = 0
        }
    }
    
    private static func formatDate(_ dateString: String) -> String {
        let input = DateFormatter()
        input.dateFormat = "yyyy-MM-dd"
        let output = DateFormatter()
        output.dateFormat = "MMM d, yyyy"
        if let date = input.date(from: dateString) {
            return output.string(from: date)
        }
        return dateString
    }
}

// MARK: - Debug Info

struct DebugInfo {
    let uniformServiceCallTimeMs: Double?
    let visitorEndpointTimeMs: Double?
    let uniformRouteTimeMs: Double?
    let processCompositionTimeMs: Double?
    let xVercelCache: String?
    let cfCacheStatus: String?
    let uniformApiCacheStatus: String?
}

// MARK: - Visitor Profile Models

struct VisitorReservation {
    let confirmationNumber: String
    let hotelName: String
    let checkIn: String
    let checkOut: String
}

struct VisitorProfile: Identifiable {
    let id: String
    let name: String
    let audience: String
    let zipCode: String
    let geoProximity: String
    let reservation: VisitorReservation?
    let membershipStatus: String
}

extension VisitorProfile {
    static let allProfiles: [VisitorProfile] = [
        VisitorProfile(id: "1", name: "Marcus Chen", audience: "loyalists", zipCode: "13478", geoProximity: "local",
                       reservation: VisitorReservation(confirmationNumber: "TS-20260315-8841", hotelName: "The Lodge", checkIn: "2026-03-15", checkOut: "2026-03-18"),
                       membershipStatus: "member"),
        VisitorProfile(id: "2", name: "Priya Patel", audience: "golf", zipCode: "13440", geoProximity: "local",
                       reservation: VisitorReservation(confirmationNumber: "TS-20260401-2294", hotelName: "The Tower", checkIn: "2026-04-01", checkOut: "2026-04-04"),
                       membershipStatus: "member"),
        VisitorProfile(id: "3", name: "Sofia Rodriguez", audience: "leisure", zipCode: "10001", geoProximity: "out-of-towner",
                       reservation: VisitorReservation(confirmationNumber: "TS-20260320-5537", hotelName: "The Lodge", checkIn: "2026-03-20", checkOut: "2026-03-23"),
                       membershipStatus: "non-member"),
        VisitorProfile(id: "4", name: "James O'Brien", audience: "corporate", zipCode: "13502", geoProximity: "local",
                       reservation: nil,
                       membershipStatus: "member"),
        VisitorProfile(id: "5", name: "Aisha Johnson", audience: "wellness", zipCode: "02101", geoProximity: "out-of-towner",
                       reservation: VisitorReservation(confirmationNumber: "TS-20260510-7712", hotelName: "The Tower", checkIn: "2026-05-10", checkOut: "2026-05-14"),
                       membershipStatus: "non-member"),
        VisitorProfile(id: "6", name: "Dmitri Volkov", audience: "golf", zipCode: "13413", geoProximity: "local",
                       reservation: VisitorReservation(confirmationNumber: "TS-20260328-3309", hotelName: "The Lodge", checkIn: "2026-03-28", checkOut: "2026-03-30"),
                       membershipStatus: "member"),
        VisitorProfile(id: "7", name: "Hannah Kim", audience: "corporate", zipCode: "60601", geoProximity: "out-of-towner",
                       reservation: VisitorReservation(confirmationNumber: "TS-20260415-6601", hotelName: "The Tower", checkIn: "2026-04-15", checkOut: "2026-04-17"),
                       membershipStatus: "non-member"),
        VisitorProfile(id: "8", name: "Luca Moretti", audience: "loyalists", zipCode: "13476", geoProximity: "local",
                       reservation: VisitorReservation(confirmationNumber: "TS-20260601-4450", hotelName: "The Lodge", checkIn: "2026-06-01", checkOut: "2026-06-05"),
                       membershipStatus: "member"),
        VisitorProfile(id: "9", name: "Tanya Brooks", audience: "leisure", zipCode: "13421", geoProximity: "local",
                       reservation: nil,
                       membershipStatus: "non-member"),
        VisitorProfile(id: "10", name: "Erik Johansson", audience: "wellness", zipCode: "19103", geoProximity: "out-of-towner",
                       reservation: VisitorReservation(confirmationNumber: "TS-20260720-1187", hotelName: "The Tower", checkIn: "2026-07-20", checkOut: "2026-07-24"),
                       membershipStatus: "member"),
    ]
}
