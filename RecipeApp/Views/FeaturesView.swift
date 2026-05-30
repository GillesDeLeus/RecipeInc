import SwiftUI

struct FeaturesView: View {

    @Environment(AppSettings.self) private var appSettings

    private var lang: AppLanguage { appSettings.language }

    var body: some View {
        @Bindable var settings = appSettings
        List {
            featureRow(
                isOn: $settings.featureShopping,
                label: lang.featureShoppingLabel,
                description: lang.featureShoppingDesc,
                icon: "checklist",
                color: .teal
            )
            featureRow(
                isOn: $settings.featureStorage,
                label: lang.featureStorageLabel,
                description: lang.featureStorageDesc,
                icon: "cart",
                color: .green
            )
            featureRow(
                isOn: $settings.featureCalendar,
                label: lang.featureCalendarLabel,
                description: lang.featureCalendarDesc,
                icon: "calendar",
                color: .blue
            )
            featureRow(
                isOn: $settings.featureAIImport,
                label: lang.featureAILabel,
                description: lang.featureAIDesc,
                icon: "sparkles",
                color: .purple
            )
            featureRow(
                isOn: $settings.featureNutrition,
                label: lang.featureNutritionLabel,
                description: lang.featureNutritionDesc,
                icon: "chart.bar",
                color: .orange
            )
        }
        .navigationTitle(lang.featuresTitle)
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
