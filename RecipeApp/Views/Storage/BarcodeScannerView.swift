#if os(iOS)
import SwiftUI
import Vision
import VisionKit
import OSLog

private let logger = Logger(subsystem: "com.recipeapp", category: "BarcodeScanner")

struct BarcodeScannerView: UIViewControllerRepresentable {

    let onScan: (String) -> Void
    let onCancel: () -> Void

    func makeUIViewController(context: Context) -> DataScannerViewController {
        logger.debug("makeUIViewController — isSupported=\(DataScannerViewController.isSupported), isAvailable=\(DataScannerViewController.isAvailable)")
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.barcode(symbologies: [
                .ean13, .ean8, .upce, .code128, .code39, .qr
            ])],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        logger.debug("updateUIViewController — hasStarted=\(context.coordinator.hasStarted)")
        guard !context.coordinator.hasStarted else { return }
        context.coordinator.hasStarted = true
        DispatchQueue.main.async {
            logger.debug("startScanning() — isAvailable=\(DataScannerViewController.isAvailable), viewLoaded=\(uiViewController.isViewLoaded), window=\(uiViewController.view.window != nil)")
            do {
                try uiViewController.startScanning()
                logger.debug("startScanning() succeeded")
            } catch {
                logger.error("startScanning() threw: \(error)")
            }
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(onScan: onScan, onCancel: onCancel) }

    // MARK: - Coordinator

    final class Coordinator: NSObject, DataScannerViewControllerDelegate {

        let onScan: (String) -> Void
        let onCancel: () -> Void
        var hasStarted = false
        private var hasScanned = false

        init(onScan: @escaping (String) -> Void, onCancel: @escaping () -> Void) {
            self.onScan = onScan
            self.onCancel = onCancel
        }

        func dataScanner(_ dataScanner: DataScannerViewController,
                         didAdd addedItems: [RecognizedItem],
                         allItems: [RecognizedItem]) {
            logger.debug("didAdd items: \(addedItems.count)")
            guard !hasScanned else { return }
            for item in addedItems {
                if case .barcode(let barcode) = item,
                   let payload = barcode.payloadStringValue,
                   !payload.isEmpty {
                    logger.debug("barcode scanned: \(payload)")
                    hasScanned = true
                    dataScanner.stopScanning()
                    onScan(payload)
                    return
                }
            }
        }

        func dataScannerDidZoom(_ dataScanner: DataScannerViewController) {
            logger.debug("dataScannerDidZoom")
        }

        func dataScanner(_ dataScanner: DataScannerViewController,
                         becameUnavailableWithError error: DataScannerViewController.ScanningUnavailable) {
            logger.error("becameUnavailableWithError: \(error.localizedDescription) — calling onCancel()")
            onCancel()
        }
    }
}

// MARK: - Sheet wrapper

struct BarcodeScannerSheet: View {

    let onScan: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            BarcodeScannerView(onScan: { code in
                onScan(code)
                dismiss()
            }, onCancel: { dismiss() })
            .ignoresSafeArea()

            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.white)
                    .padding()
            }
        }
    }
}
#endif
