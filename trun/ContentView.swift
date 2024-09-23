import SwiftUI
import UIKit
import MapKit

struct ContentView: View {
    @State private var showDocumentPicker = false
    @State private var selectedFile: URL?

    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: SecondView()) {
                    Text("Go to Second Screen")
                }
            }
            .navigationTitle("First Screen")
        }
        VStack {
            Button(action: {
                self.showDocumentPicker = true
            }) {
                Text("Select File")
            }
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker(selectedFileURL: self.$selectedFile)
            }

            if let file = selectedFile {
                Text("Selected: \(file.lastPathComponent)")
            }
        }
    }
}

struct SecondView: View {
    var body: some View {
        MapView().navigationTitle("Running Map")
    }
}

struct MapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.334900, longitude: -122.009020), // Example: Apple HQ
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )

    var body: some View {
        Map(coordinateRegion: $region)
            .edgesIgnoringSafeArea(.all) // If you want the map to extend under navigation bars or tab bars
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}

struct DocumentPicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedFileURL: URL?

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // Update logic if needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate, UINavigationControllerDelegate {
        let parent: DocumentPicker

        init(_ parent: DocumentPicker) {
            self.parent = parent
        }

        private func documentPicker(_ controller: UIDocumentPickerViewController, urls: [URL]) {
            guard let url = urls.first else { return }
            parent.selectedFileURL = url
            parent.presentationMode.wrappedValue.dismiss()
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
