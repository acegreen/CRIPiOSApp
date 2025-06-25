//
//  InterestsSettingsView.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-06-25.
//

import SwiftUI

struct InterestsSettingsView: View {
    @Binding var viewModel: CelebrityViewModel
    @Environment(\.dismiss) private var dismiss
    
    var interests: [String] { UserInterests.availableInterests }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Text("Tell us what you're into.")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top)
                Text("Tap on the ones you like. Tap again to deselect.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 16)
                
                BubbleWrapView(
                    data: interests,
                    spacing: 16
                ) { interest in
                    InterestBubble(
                        title: interest,
                        isSelected: viewModel.userInterests.selectedInterests.contains(interest)
                    )
                    .onTapGesture {
                        if viewModel.userInterests.selectedInterests.contains(interest) {
                            viewModel.removeUserInterest(interest)
                        } else {
                            viewModel.addUserInterest(interest)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                
                HStack {
                    Button("Reset") {
                        viewModel.userInterests.selectedInterests.removeAll()
                        viewModel.saveUserInterests()
                    }
                    .foregroundColor(.accentColor)
                    .padding(.leading)
                    
                    Spacer()
                    
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .padding(.trailing)
                }
                .padding(.vertical)
            }
            .navigationBarHidden(true)
        }
    }
}

struct InterestBubble: View {
    let title: String
    let isSelected: Bool
    var body: some View {
        Text(title)
            .font(.body)
            .padding(.vertical, 18)
            .padding(.horizontal, 24)
            .background(isSelected ? Color.accentColor : Color.gray.opacity(0.15))
            .foregroundColor(isSelected ? .white : .primary)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isSelected ? 1.08 : 1.0)
            .shadow(color: isSelected ? Color.accentColor.opacity(0.2) : .clear, radius: 6, x: 0, y: 2)
            .animation(.spring(), value: isSelected)
    }
}

// A simple wrapping layout for bubbles
struct BubbleWrapView<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let content: (Data.Element) -> Content
    
    @State private var totalHeight: CGFloat = .zero
    
    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
        .frame(height: totalHeight)
    }
    
    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        return ZStack(alignment: .topLeading) {
            ForEach(Array(data), id: \.self) { item in
                content(item)
                    .padding(.all, 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if abs(width - d.width) > geometry.size.width {
                            width = 0
                            height -= d.height + spacing
                        }
                        let result = width
                        if item == data.last {
                            width = 0 // Last item
                        } else {
                            width -= d.width + spacing
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { _ in
                        let result = height
                        if item == data.last {
                            height = 0 // Last item
                        }
                        return result
                    })
            }
        }
        .background(viewHeightReader($totalHeight))
    }
    
    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        GeometryReader { geometry in
            Color.clear
                .preference(key: HeightPreferenceKey.self, value: geometry.size.height)
        }
        .onPreferenceChange(HeightPreferenceKey.self) { binding.wrappedValue = $0 }
    }
}

private struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
