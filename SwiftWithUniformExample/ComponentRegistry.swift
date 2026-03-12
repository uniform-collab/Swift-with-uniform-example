//
//  ComponentRegistry.swift
//  SwiftWithUniformExample
//

import SwiftUI

struct ComponentRegistry {
    
    // MARK: - Data Mapping (SlotComponent → MainContentItem)
    
    static func mapComponent(
        _ component: SlotComponent,
        slides: [CarouselSlideViewModel],
        profile: VisitorProfile?
    ) -> MainContentItem? {
        switch component.type {
        case "carousel":
            return .carousel(slides)
        case "upcomingReservation":
            let vm = UpcomingReservationViewModel(
                title: component.parameters?.title?.value ?? "Upcoming Reservation",
                checkInLabel: component.parameters?.checkInLabel?.value ?? "CHECK-IN",
                checkOutLabel: component.parameters?.checkOutLabel?.value ?? "CHECK-OUT",
                reservation: ReservationViewModel(from: profile?.reservation)
            )
            return .upcomingReservation(vm)
        case "promotion":
            let vm = PromotionViewModel(
                title: component.parameters?.title?.value ?? "",
                description: component.parameters?.description?.value ?? "",
                ctaText: component.parameters?.ctaText?.value ?? "",
                ctaUrl: component.parameters?.ctaLink?.value.path,
                imageUrl: component.parameters?.image?.firstImageUrl
            )
            return .promotion(vm)
        default:
            return nil
        }
    }
    
    // MARK: - View Mapping (MainContentItem → SwiftUI View)
    
    @ViewBuilder
    static func view(for item: MainContentItem) -> some View {
        switch item {
        case .carousel(let slides):
            CarouselView(slides: slides)
                .frame(height: 300)
        case .upcomingReservation(let vm):
            ReservationCardView(viewModel: vm)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
        case .promotion(let vm):
            PromotionView(viewModel: vm)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
        }
    }
}
