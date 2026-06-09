import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct CookModeView: View {

    let recipe: Recipe
    let portions: Int

    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) private var appSettings

    @State private var currentStep = 0
    @State private var showingIngredients = false
    @State private var wakeToken: AnyObject? = nil

    // FocusState lets us capture arrow-key presses on macOS
    @FocusState private var isFocused: Bool


    // MARK: - Step parsing

    private var steps: [String] {
        let text = recipe.instructions.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return [] }

        // Prefer double-newline paragraph splits
        let byParagraph = text
            .components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        if byParagraph.count > 1 { return byParagraph }

        // Fall back to single-line splits
        let byLine = text
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return byLine.count > 1 ? byLine : [text]
    }

    private var isFirst: Bool { currentStep == 0 }
    private var isLast:  Bool { currentStep >= steps.count - 1 }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if steps.isEmpty {
                emptyState
            } else {
                VStack(spacing: 0) {
                    header
                    Divider().overlay(Color.white.opacity(0.1))
                    stepContent
                    progressIndicator
                    navigationButtons
                }
            }
        }
        .focusable()
        .focused($isFocused)
        .onKeyPress(.leftArrow)  { goPrev(); return .handled }
        .onKeyPress(.rightArrow) { if isLast { dismiss() } else { goNext() }; return .handled }
        .onAppear  { isFocused = true; keepAwake() }
        .onDisappear { allowSleep() }
        .sheet(isPresented: $showingIngredients) {
            CookModeIngredientsView(recipe: recipe, portions: portions)
                .environment(appSettings)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.regularMaterial)
        }
    }

    // MARK: - Sub-views

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "text.page.slash")
                .font(.system(size: 56))
                .foregroundStyle(.gray)
            Text(String(localized: "No preparation steps found.\nAdd instructions to your recipe first."))
                .font(.body)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button(String(localized: "Done")) { dismiss() }
                .buttonStyle(.bordered)
                .tint(.white)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var header: some View {
        HStack(spacing: 16) {
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)

            Spacer()

            VStack(spacing: 3) {
                Text(recipe.name)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(String(localized: "Step \(currentStep + 1) of \(steps.count)"))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.55))
            }

            Spacer()

            Button { showingIngredients = true } label: {
                VStack(spacing: 2) {
                    Image(systemName: "list.bullet")
                        .font(.title3)
                    Text(String(localized: "Ingredients"))
                        .font(.caption2)
                }
                .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            .help(String(localized: "Ingredients"))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
    }

    private var stepContent: some View {
        ScrollView {
            Text(steps[currentStep])
                .font(.title2)
                .fontWeight(.regular)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(7)
                .padding(.horizontal, 48)
                .padding(.vertical, 40)
                .frame(maxWidth: 640)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 40)
                .onEnded { v in
                    if v.translation.width < -40 { isLast ? dismiss() : goNext() }
                    else if v.translation.width > 40 { goPrev() }
                }
        )
        .id(currentStep)  // Re-scrolls to top when step changes
        .accessibilityLabel(String(localized: "Step \(currentStep + 1) of \(steps.count)") + ": " + steps[currentStep])
        .accessibilityAction(named: String(localized: "Previous")) { goPrev() }
        .accessibilityAction(named: isLast ? String(localized: "Done Cooking") : String(localized: "Next")) {
            isLast ? dismiss() : goNext()
        }
    }

    private var progressIndicator: some View {
        Group {
            if steps.count > 1 {
                if steps.count <= 12 {
                    HStack(spacing: 6) {
                        ForEach(0..<steps.count, id: \.self) { i in
                            Capsule()
                                .fill(i == currentStep
                                      ? Color.white
                                      : Color.white.opacity(0.22))
                                .frame(width: i == currentStep ? 22 : 8, height: 8)
                        }
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.75), value: currentStep)
                    .padding(.bottom, 12)
                } else {
                    ProgressView(value: Double(currentStep + 1), total: Double(steps.count))
                        .progressViewStyle(.linear)
                        .tint(.white)
                        .frame(maxWidth: 320)
                        .padding(.bottom, 12)
                }
            }
        }
    }

    private var navigationButtons: some View {
        HStack(spacing: 12) {
            // Previous
            Button(action: goPrev) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                    Text(String(localized: "Previous"))
                }
                .font(.headline)
                .foregroundStyle(isFirst ? .white.opacity(0.2) : .white)
                .padding(.horizontal, 22).padding(.vertical, 13)
                .background(Color.white.opacity(isFirst ? 0.04 : 0.12))
                .clipShape(RoundedRectangle(cornerRadius: 13))
            }
            .buttonStyle(.plain)
            .disabled(isFirst)

            Spacer()

            // Next / Finish
            Button { if isLast { dismiss() } else { goNext() } } label: {
                HStack(spacing: 6) {
                    Text(isLast ? String(localized: "Done Cooking") : String(localized: "Next"))
                    if !isLast { Image(systemName: "chevron.right") }
                }
                .font(.headline)
                .foregroundStyle(isLast ? .black : .white)
                .padding(.horizontal, 22).padding(.vertical, 13)
                .background(isLast ? Color.white : Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 13))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 32)
        .padding(.top, 8)
        .padding(.bottom, 28)
    }

    // MARK: - Navigation helpers

    private func goNext() {
        guard !isLast else { return }
        withAnimation(.easeInOut(duration: 0.18)) { currentStep += 1 }
    }

    private func goPrev() {
        guard !isFirst else { return }
        withAnimation(.easeInOut(duration: 0.18)) { currentStep -= 1 }
    }

    // MARK: - Screen wake

    private func keepAwake() {
#if canImport(UIKit)
        UIApplication.shared.isIdleTimerDisabled = true
#else
        wakeToken = ProcessInfo.processInfo.beginActivity(
            options: [.userInitiated, .idleDisplaySleepDisabled],
            reason: "Cook Mode"
        ) as AnyObject
#endif
    }

    private func allowSleep() {
#if canImport(UIKit)
        UIApplication.shared.isIdleTimerDisabled = false
#else
        if let token = wakeToken as? NSObjectProtocol {
            ProcessInfo.processInfo.endActivity(token)
            wakeToken = nil
        }
#endif
    }
}

// MARK: - Ingredients reference sheet

private struct CookModeIngredientsView: View {

    let recipe: Recipe
    let portions: Int

    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) private var appSettings

    var body: some View {
        NavigationStack {
            List {
                let sorted = recipe.recipeIngredients
                    .sorted { ($0.ingredient?.name ?? "") < ($1.ingredient?.name ?? "") }
                ForEach(sorted) { line in
                    if let ingredient = line.ingredient {
                        HStack {
                            Text(ingredient.name)
                            Spacer()
                            let scaled = line.amount * Double(portions)
                            let amtStr = scaled.truncatingRemainder(dividingBy: 1) == 0
                                ? String(Int(scaled))
                                : String(format: "%.1f", scaled)
                            Text(ingredient.unit.isEmpty ? amtStr : "\(amtStr) \(ingredient.unit)")
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                    }
                }
            }
            .navigationTitle(portions == 1
                             ? String(localized: "Ingredients")
                             : "\(String(localized: "Ingredients")) (×\(portions))")
            .navigationTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Done")) { dismiss() }
                }
            }
        }
    }
}
