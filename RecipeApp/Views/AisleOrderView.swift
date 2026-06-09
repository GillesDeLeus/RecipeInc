import SwiftUI

struct AisleOrderView: View {

    @Environment(AppSettings.self) private var appSettings


    var body: some View {
        @Bindable var settings = appSettings
        List {
            Section {
                ForEach(settings.aisleOrder, id: \.self) { category in
                    Label(category.localizedName, systemImage: category.icon)
                }
                .onMove { from, to in
                    settings.aisleOrder.move(fromOffsets: from, toOffset: to)
                }
            } footer: {
                Text(String(localized: "Drag categories to match your store's layout. The shopping list groups items in this order."))
            }
        }
        #if os(iOS)
        .environment(\.editMode, .constant(.active))
        #endif
        .navigationTitle(String(localized: "Aisle Order"))
        .navigationTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(String(localized: "Reset")) {
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
