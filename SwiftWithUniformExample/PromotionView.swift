//
//  PromotionView.swift
//  SwiftWithUniformExample
//

import SwiftUI

struct PromotionView: View {
    let viewModel: PromotionViewModel
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [.clear, .black.opacity(0.75)],
                startPoint: .init(x: 0.5, y: 0.25),
                endPoint: .bottom
            )
            
            VStack(alignment: .leading, spacing: 10) {
                Spacer()
                
                Text(viewModel.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(viewModel.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(3)
                
                if !viewModel.ctaText.isEmpty {
                    Button(action: {
                        if let urlString = viewModel.ctaUrl,
                           let url = URL(string: urlString) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text(viewModel.ctaText)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(Color.white)
                            .cornerRadius(20)
                    }
                    .padding(.top, 4)
                }
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 260)
        .background(backgroundImage)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
    }
    
    @ViewBuilder
    private var backgroundImage: some View {
        if let urlString = viewModel.imageUrl, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                if case .success(let image) = phase {
                    image.resizable().scaledToFill()
                } else {
                    placeholderBackground
                }
            }
        } else {
            placeholderBackground
        }
    }
    
    private var placeholderBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.55, green: 0.42, blue: 0.32),
                    Color(red: 0.30, green: 0.22, blue: 0.18)
                ],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )
            
            Image(systemName: "leaf.fill")
                .font(.system(size: 140))
                .foregroundColor(.white.opacity(0.06))
                .rotationEffect(.degrees(-20))
                .offset(x: 90, y: -30)
        }
    }
}
