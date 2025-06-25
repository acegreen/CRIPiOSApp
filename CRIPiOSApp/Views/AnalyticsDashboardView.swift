//
//  AnalyticsDashboardView.swift
//  CRIPiOSApp
//
//  Created by AceGreen on 2025-06-25.
//

import SwiftUI

struct AnalyticsDashboardView: View {
    @Binding var viewModel: AnalyticsViewModel
    @Binding var celebrityViewModel: CelebrityViewModel
    @State private var selectedTimeframe: Timeframe = .allTime
    @State private var selectedTab = 0
    @State private var refreshTrigger = false
    
    init(viewModel: Binding<AnalyticsViewModel>, celebrityViewModel: Binding<CelebrityViewModel>) {
        self._viewModel = viewModel
        self._celebrityViewModel = celebrityViewModel
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with filters
                VStack(spacing: 12) {
                    // Timeframe picker
                    Picker("Timeframe", selection: $selectedTimeframe) {
                        ForEach(Timeframe.allCases, id: \.self) { timeframe in
                            Text(timeframe.displayName).tag(timeframe)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    // Filter picker
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            AnalyticsFilterChip(
                                title: "Overview",
                                icon: "chart.bar.fill",
                                isSelected: selectedTab == 0
                            ) {
                                selectedTab = 0
                            }
                            
                            AnalyticsFilterChip(
                                title: "Trends",
                                icon: "chart.line.uptrend.xyaxis",
                                isSelected: selectedTab == 1
                            ) {
                                selectedTab = 1
                            }
                            
                            AnalyticsFilterChip(
                                title: "Predictions",
                                icon: "crystal.ball",
                                isSelected: selectedTab == 2
                            ) {
                                selectedTab = 2
                            }
                            
                            AnalyticsFilterChip(
                                title: "Historical",
                                icon: "clock.arrow.circlepath",
                                isSelected: selectedTab == 3
                            ) {
                                selectedTab = 3
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                
                // Content based on selected tab
                VStack(spacing: 0) {
                    // Content
                    TabView(selection: $selectedTab) {
                        AnalyticsOverviewTabView(
                            analyticsViewModel: $viewModel, 
                            celebrityViewModel: $celebrityViewModel,
                            timeframe: selectedTimeframe
                        )
                            .tag(0)
                        
                        AnalyticsTrendsTabView(
                            analyticsViewModel: $viewModel, 
                            celebrityViewModel: $celebrityViewModel,
                            timeframe: selectedTimeframe
                        )
                            .tag(1)
                        
                        AnalyticsPredictionsTabView(
                            analyticsViewModel: $viewModel,
                            celebrityViewModel: $celebrityViewModel
                        )
                            .tag(2)
                        
                        AnalyticsHistoricalTabView(
                            analyticsViewModel: $viewModel,
                            celebrityViewModel: $celebrityViewModel
                        )
                            .tag(3)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await refreshData()
            }
            .onChange(of: selectedTimeframe) { _ in
                refreshData()
            }
        }
    }
    
    private func refreshData() async {
        // Simulate a brief loading time for better UX
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Update the refresh trigger to force view updates
        refreshTrigger.toggle()
    }
    
    private func refreshData() {
        // Update the refresh trigger to force view updates
        refreshTrigger.toggle()
    }
}

// MARK: - Filter Chip
struct AnalyticsFilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Key Metrics Section
struct KeyMetricsSection: View {
    @Binding var analyticsViewModel: AnalyticsViewModel
    @Binding var celebrityViewModel: CelebrityViewModel
    let timeframe: Timeframe

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Key Metrics")
                .font(.headline)
                .fontWeight(.semibold)

            let celebrities = celebrityViewModel.fetchCelebrities()
            let stats = analyticsViewModel.getStatistics(for: timeframe, celebrities: celebrities)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                DashboardMetricCard(
                    title: "Total Celebrities",
                    value: "\(stats.total)",
                    subtitle: "Tracked",
                    icon: "person.3.fill",
                    color: .blue,
                    trend: "+5%"
                )

                DashboardMetricCard(
                    title: "Mortality Rate",
                    value: "\(String(format: "%.1f", mortalityRate(stats)))%",
                    subtitle: "Current",
                    icon: "heart.slash.fill",
                    color: .red,
                    trend: "-2%"
                )

                DashboardMetricCard(
                    title: "Average Age",
                    value: "\(stats.averageAge)",
                    subtitle: "Years",
                    icon: "calendar",
                    color: .orange,
                    trend: "+1.2"
                )

                DashboardMetricCard(
                    title: "High Risk",
                    value: "\(highRiskCount(celebrities: celebrities))",
                    subtitle: "Celebrities",
                    icon: "exclamationmark.triangle.fill",
                    color: .purple,
                    trend: "+3"
                )
            }
        }
    }

    private func mortalityRate(_ stats: CelebrityStatistics) -> Double {
        guard stats.total > 0 else { return 0 }
        return (Double(stats.deceased) / Double(stats.total)) * 100
    }
    
    private func highRiskCount(celebrities: [Celebrity]) -> Int {
        let predictions = analyticsViewModel.getLongevityPredictions(celebrities: celebrities)
        return predictions.filter { $0.riskScore > 0.7 }.count
    }
}

// MARK: - Death Trends Section
struct DeathTrendsSection: View {
    @Binding var analyticsViewModel: AnalyticsViewModel
    @Binding var celebrityViewModel: CelebrityViewModel
    let timeframe: Timeframe

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Death Trends Analysis")
                .font(.headline)
                .fontWeight(.semibold)

            let celebrities = celebrityViewModel.fetchCelebrities()
            let trends = analyticsViewModel.getDeathTrendsAnalysis(for: timeframe, celebrities: celebrities)

            // Age Distribution Chart
            VStack(alignment: .leading, spacing: 12) {
                Text("Age Distribution at Death")
                    .font(.subheadline)
                    .fontWeight(.medium)

                AgeDistributionChart(ageDistribution: trends.ageDistribution)
                    .frame(height: 200)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)

            // Occupation Risk Analysis
            VStack(alignment: .leading, spacing: 12) {
                Text("Occupation Risk Analysis")
                    .font(.subheadline)
                    .fontWeight(.medium)

                ForEach(Array(trends.occupationRisk.prefix(5)), id: \.key) { occupation, risk in
                    HStack {
                        Text(occupation)
                            .font(.body)
                            .lineLimit(1)

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(String(format: "%.1f", risk))%")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(riskColor(risk))

                            ProgressView(value: risk, total: 100)
                                .progressViewStyle(LinearProgressViewStyle(tint: riskColor(risk)))
                                .frame(width: 80)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }

    private func riskColor(_ risk: Double) -> Color {
        switch risk {
        case 0..<20: return .green
        case 20..<40: return .yellow
        case 40..<60: return .orange
        default: return .red
        }
    }
}

// MARK: - Longevity Predictions Section
struct LongevityPredictionsSection: View {
    @Binding var analyticsViewModel: AnalyticsViewModel
    @Binding var celebrityViewModel: CelebrityViewModel
    let filter: AnalyticsFilter

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Longevity Predictions")
                .font(.headline)
                .fontWeight(.semibold)

            let celebrities = celebrityViewModel.fetchCelebrities()
            let predictions = filteredPredictions(celebrities: celebrities)

            ForEach(predictions.prefix(5), id: \.celebrityId) { prediction in
                LongevityPredictionCard(prediction: prediction)
            }
        }
    }

    private func filteredPredictions(celebrities: [Celebrity]) -> [LongevityPrediction] {
        let predictions = analyticsViewModel.getLongevityPredictions(celebrities: celebrities)

        switch filter {
        case .all:
            return predictions
        case .highRisk:
            return predictions.filter { $0.riskScore > 0.7 }
        case .mediumRisk:
            return predictions.filter { $0.riskScore >= 0.4 && $0.riskScore <= 0.7 }
        case .lowRisk:
            return predictions.filter { $0.riskScore < 0.4 }
        }
    }
}

// MARK: - Historical Comparison Section
struct HistoricalComparisonSection: View {
    @Binding var analyticsViewModel: AnalyticsViewModel
    @Binding var celebrityViewModel: CelebrityViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Historical Comparisons")
                .font(.headline)
                .fontWeight(.semibold)

            let celebrities = celebrityViewModel.fetchCelebrities()
            let comparison = analyticsViewModel.getHistoricalComparison(celebrities: celebrities)

            VStack(alignment: .leading, spacing: 12) {
                Text("Trend Analysis")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(comparison.trendAnalysis)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)

            // Decade Comparison
            HStack(spacing: 16) {
                DecadeComparisonCard(
                    title: "Current Decade",
                    decade: comparison.currentDecade
                )

                DecadeComparisonCard(
                    title: "Previous Decade",
                    decade: comparison.previousDecade
                )
            }
        }
    }
}

// MARK: - Interactive Charts Section
struct InteractiveChartsSection: View {
    @Binding var analyticsViewModel: AnalyticsViewModel
    @Binding var celebrityViewModel: CelebrityViewModel
    let timeframe: Timeframe

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Interactive Charts")
                .font(.headline)
                .fontWeight(.semibold)

            let celebrities = celebrityViewModel.fetchCelebrities()
            let trends = analyticsViewModel.getDeathTrendsAnalysis(for: timeframe, celebrities: celebrities)

            // Yearly Trends Chart
            VStack(alignment: .leading, spacing: 12) {
                Text("Yearly Death Trends")
                    .font(.subheadline)
                    .fontWeight(.medium)

                YearlyTrendsChart(yearlyTrends: trends.yearlyTrends)
                    .frame(height: 200)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)

            // Monthly Patterns Chart
            VStack(alignment: .leading, spacing: 12) {
                Text("Monthly Death Patterns")
                    .font(.subheadline)
                    .fontWeight(.medium)

                MonthlyPatternChart(monthlyPatterns: trends.monthlyPatterns)
                    .frame(height: 150)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

// MARK: - AI Insights Section
struct AIInsightsSection: View {
    @Binding var analyticsViewModel: AnalyticsViewModel
    @Binding var celebrityViewModel: CelebrityViewModel
    @State private var insights: [AnalyticsInsight] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AI-Generated Insights")
                .font(.headline)
                .fontWeight(.semibold)

            if insights.isEmpty {
                Button("Generate Insights") {
                    generateInsights()
                }
                .buttonStyle(.borderedProminent)
            } else {
                ForEach(Array(insights.enumerated()), id: \.offset) { index, insight in
                    InsightCard(insight: insight) {
                        // Handle insight tap
                    }
                }
            }
        }
    }

    private func generateInsights() {
        let celebrities = celebrityViewModel.fetchCelebrities()
        // Generate insights based on celebrity data
        insights = [
            AnalyticsInsight(
                type: .age,
                title: "Age Distribution",
                description: "The average age of deceased celebrities is \(calculateAverageAge(celebrities)) years",
                significance: .high,
                data: calculateAverageAge(celebrities)
            ),
            AnalyticsInsight(
                type: .occupation,
                title: "Occupation Risk",
                description: "Actors and musicians show higher mortality rates compared to other professions",
                significance: .medium,
                data: 75
            ),
            AnalyticsInsight(
                type: .temporal,
                title: "Seasonal Patterns",
                description: "Deaths tend to peak during winter months",
                significance: .medium,
                data: 60
            )
        ]
    }
    
    private func calculateAverageAge(_ celebrities: [Celebrity]) -> Int {
        let deceased = celebrities.filter { $0.isDeceased }
        guard !deceased.isEmpty else { return 0 }
        return deceased.map { $0.age }.reduce(0, +) / deceased.count
    }
}

// MARK: - Supporting Views
struct DashboardMetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    let trend: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)

                Spacer()

                Text(trend)
                    .font(.caption)
                    .foregroundColor(trend.hasPrefix("+") ? .green : .red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background((trend.hasPrefix("+") ? Color.green : Color.red).opacity(0.1))
                    .cornerRadius(8)
            }

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)

            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct LongevityPredictionCard: View {
    let prediction: LongevityPrediction

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(prediction.celebrityName)
                    .font(.body)
                    .fontWeight(.medium)

                Spacer()

                Text("\(String(format: "%.0f", prediction.riskScore))%")
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundColor(riskColor(prediction.riskScore))
            }

            HStack {
                Text("Predicted: \(prediction.predictedLifespan) years")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text("Confidence: \(String(format: "%.0f", prediction.confidence))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if !prediction.riskFactors.isEmpty {
                HStack {
                    ForEach(prediction.riskFactors.prefix(2), id: \.self) { factor in
                        Text(factor)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(.red)
                            .cornerRadius(4)
                    }
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }

    private func riskColor(_ risk: Double) -> Color {
        switch risk {
        case 0..<30: return .green
        case 30..<50: return .yellow
        case 50..<70: return .orange
        default: return .red
        }
    }
}

struct DecadeComparisonCard: View {
    let title: String
    let decade: DecadeStats

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Avg Age:")
                    Spacer()
                    Text("\(String(format: "%.1f", decade.averageAge))")
                        .fontWeight(.semibold)
                }

                HStack {
                    Text("Deaths:")
                    Spacer()
                    Text("\(decade.totalDeaths)")
                        .fontWeight(.semibold)
                }
            }
            .font(.caption)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Enums
enum AnalyticsFilter: String, CaseIterable {
    case all = "all"
    case highRisk = "highRisk"
    case mediumRisk = "mediumRisk"
    case lowRisk = "lowRisk"
    
    var displayName: String {
        switch self {
        case .all: return "All"
        case .highRisk: return "High"
        case .mediumRisk: return "Medium"
        case .lowRisk: return "Low"
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "list.bullet"
        case .highRisk: return "exclamationmark.triangle.fill"
        case .mediumRisk: return "exclamationmark.triangle"
        case .lowRisk: return "checkmark.circle"
        }
    }
}

// MARK: - Tab Views
struct AnalyticsOverviewTabView: View {
    @Binding var analyticsViewModel: AnalyticsViewModel
    @Binding var celebrityViewModel: CelebrityViewModel
    let timeframe: Timeframe
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Key Metrics Overview
                KeyMetricsSection(analyticsViewModel: $analyticsViewModel, celebrityViewModel: $celebrityViewModel, timeframe: timeframe)
                
                // AI Insights
                AIInsightsSection(analyticsViewModel: $analyticsViewModel, celebrityViewModel: $celebrityViewModel)
                
                // Interactive Charts
                InteractiveChartsSection(analyticsViewModel: $analyticsViewModel, celebrityViewModel: $celebrityViewModel, timeframe: timeframe)
            }
            .padding()
        }
    }
}

struct AnalyticsTrendsTabView: View {
    @Binding var analyticsViewModel: AnalyticsViewModel
    @Binding var celebrityViewModel: CelebrityViewModel
    let timeframe: Timeframe
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Death Trends Analysis
                DeathTrendsSection(analyticsViewModel: $analyticsViewModel, celebrityViewModel: $celebrityViewModel, timeframe: timeframe)
            }
            .padding()
        }
    }
}

struct AnalyticsPredictionsTabView: View {
    @Binding var analyticsViewModel: AnalyticsViewModel
    @Binding var celebrityViewModel: CelebrityViewModel
    @State private var selectedRiskFilter: AnalyticsFilter = .all
    
    var body: some View {
        VStack(spacing: 0) {
            // Risk filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(AnalyticsFilter.allCases, id: \.self) { filter in
                        AnalyticsFilterChip(
                            title: filter.displayName,
                            icon: filter.icon,
                            isSelected: selectedRiskFilter == filter
                        ) {
                            selectedRiskFilter = filter
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            
            // Predictions content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Longevity Predictions
                    LongevityPredictionsSection(analyticsViewModel: $analyticsViewModel, celebrityViewModel: $celebrityViewModel, filter: selectedRiskFilter)
                }
                .padding()
            }
        }
    }
}

struct AnalyticsHistoricalTabView: View {
    @Binding var analyticsViewModel: AnalyticsViewModel
    @Binding var celebrityViewModel: CelebrityViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Historical Comparisons
                HistoricalComparisonSection(analyticsViewModel: $analyticsViewModel, celebrityViewModel: $celebrityViewModel)
            }
            .padding()
        }
    }
}

// MARK: - Placeholder Chart Views (to be implemented)
struct AgeDistributionChart: View {
    let ageDistribution: [AgeGroup: Int]
    
    var body: some View {
        Text("Age Distribution Chart")
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct YearlyTrendsChart: View {
    let yearlyTrends: [Int: Int]
    
    var body: some View {
        Text("Yearly Trends Chart")
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct MonthlyPatternChart: View {
    let monthlyPatterns: [Int: Int]
    
    var body: some View {
        Text("Monthly Patterns Chart")
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Placeholder Models (to be implemented)
struct InsightCard: View {
    let insight: AnalyticsInsight
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(insight.title)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Spacer()
                
                // Significance indicator
                Text(insight.significance.rawValue.capitalized)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(significanceColor(insight.significance).opacity(0.2))
                    .foregroundColor(significanceColor(insight.significance))
                    .cornerRadius(8)
            }
            
            Text(insight.description)
                .font(.body)
                .foregroundColor(.secondary)
            
            HStack {
                Text("Data: \(insight.data)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(insight.type.rawValue.capitalized)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .onTapGesture {
            // Handle insight tap
        }
    }
    
    private func significanceColor(_ significance: InsightSignificance) -> Color {
        switch significance {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        case .critical: return .purple
        }
    }
}
