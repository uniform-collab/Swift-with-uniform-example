//
//  ReservationCardView.swift
//  SwiftWithUniformExample
//

import SwiftUI

struct ReservationCardView: View {
    let viewModel: UpcomingReservationViewModel
    
    var body: some View {
        Group {
            if let reservation = viewModel.reservation {
                reservationContent(reservation)
            } else {
                noReservationContent
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
    }
    
    private func reservationContent(_ r: ReservationViewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "building.2.fill")
                    .font(.title3)
                    .foregroundColor(.accentColor)
                Text(viewModel.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(r.hotelName)
                    .font(.title3)
                    .fontWeight(.bold)
                
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.checkInLabel)
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(.secondary)
                        Text(r.formattedCheckIn)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    Image(systemName: "arrow.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.checkOutLabel)
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(.secondary)
                        Text(r.formattedCheckOut)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 2) {
                        Text("\(r.nightCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.accentColor)
                        Text(r.nightCount == 1 ? "night" : "nights")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Divider()
            
            Text(r.confirmationNumber)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.secondary)
        }
    }
    
    private var noReservationContent: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.plus")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("No upcoming reservations")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button(action: {}) {
                Text("Book a Stay")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color.accentColor)
                    .cornerRadius(20)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }
}
