import SwiftUI

struct AisleOrderView: View {

    @Environment(AppSettings.self) private var appSettings

    private var lang: AppLanguage { appSettings.language }

    var body: some View {
        @Bindable var settings = appSettings
        List {
            Section {
                ForEach(settings.aisleOrder, id: \.self) { category in
                    Label(category.localizedName(in: lang), systemImage: category.icon)
                }
                .onMove { from, to in
                    settings.aisleOrder.move(fromOffsets: from, toOffset: to)
                }
            } footer: {
                Text(lang.aisleOrderHint)
            }
        }
        #if os(iOS)
        .environment(\.editMode, .constant(.active))
        #endif
        .navigationTitle(lang.aisleOrderTitle)
        .navigationTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(lang.reset) {
                    settings.aisleOrder = ShoppingCategory.allCases
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AisleOrderView()
            .environment(AppSettings())
    }
}
