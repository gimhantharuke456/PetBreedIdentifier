import SwiftUI
import CoreML
import Vision
import PhotosUI
struct IdentifierView: View {
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var predictedLabel: String = ""
    @State private var isImageSelected: Bool = false
    
    let model: DogBreedClassifier = {
        // Load the Core ML model
        do {
            let configuration = MLModelConfiguration()
            return try DogBreedClassifier(configuration: configuration)
        } catch {
            fatalError("Couldn't load model: \(error)")
        }
    }()
    
    var body: some View {
        VStack {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Text("Select an Image")
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    // Retrieve selected asset
                    guard let selectedItem else { return }
                    // Retrieve selected asset’s data
                    if let data = try? await selectedItem.loadTransferable(type: Data.self) {
                        self.selectedImageData = data
                        self.isImageSelected = true
                        self.predictDisease(from: data)
                    }
                }
            }

            if let imageData = selectedImageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            }

            if isImageSelected {
                Text("Predicted Breed: \(predictedLabel)")
                    .font(.headline)
            }
        }
        .padding()
    }

    func predictDisease(from imageData: Data) {
        guard let model = try? VNCoreMLModel(for: self.model.model) else {
            print("Failed to load the CoreML model.")
            return
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            if let error = error {
                print("Prediction failed: \(error.localizedDescription)")
                return
            }
            guard let observations = request.results as? [VNClassificationObservation], !observations.isEmpty else {
                print("No results found.")
                return
            }
            // Get the top predicted label
            self.predictedLabel = observations.first?.identifier ?? "Unknown"
        }
        
        // Convert the selected image to the required format (CGImage)
        guard let image = UIImage(data: imageData)?.cgImage else {
            print("Unable to convert UIImage to CGImage.")
            return
        }
        
        // Perform the classification request on the image
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        try? handler.perform([request])
    }
}

#Preview {
    IdentifierView()
}
