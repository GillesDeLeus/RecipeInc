import SwiftUI

struct FeaturesView: View {

    @Environment(AppSettings.self) private var appSettings


    var body: some View {
        @Bindable var settings = appSettings
        List {
            featureRow(
                isOn: $settings.featureShopping,
                label: String(localized: "Shopping List"),
                description: String(localized: "Manually add items and generate lists from your meal plan."),
                icon: "checklist",
                color: .teal
            )
            featureRow(
                isOn: $settings.featureStorage,
                label: String(localized: "Storage"),
                description: String(localized: "Track ingredients you have at home."),
                icon: "cart",
                color: .green
            )
            featureRow(
                isOn: $settings.featureCalendar,
                label: String(localized: "Meal Calendar"),
                description: String(localized: "Plan meals and generate shopping lists."),
                icon: "calendar",
                color: .blue
            )
            featureRow(
                isOn: $settings.featureAIImport,
                label: String(localized: "AI Recipe Import"),
                description: String(localized: "Import recipes from photos or URLs using on-device AI."),
                icon: "sparkles",
                color: .purple
            )
            featureRow(
                isOn: $settings.featureNutrition,
                label: String(localized: "Nutrition"),
                description: String(localized: "Show calorie and nutrient data per recipe."),
                icon: "chart.bar",
                color: .orange
            )
        }
        .navigationTitle(String(localized: "Features"))
        .navigationTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func featureRow(isOn: Binding<Bool>, label: String, description: String,
                            icon: String, color: Color, badge: String? = nil) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color)
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .foregroundStyle(.white)
                    .font(.system(size: 16, weight: .medium))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.body)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let badge {
                    Text("⚙︎ \(badge)")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }
            Spacer()
            Toggle("", isOn: isOn).labelsHidden()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        FeaturesView()
    }
    .environment(AppSettings())
}
