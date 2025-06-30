import SwiftUI
import UniformTypeIdentifiers
import AES_128_CORE


struct ContentView: View {
    @State private var selectedMode: Mode = .encryption
    @State private var selectedOption: Options = .seq
    @State private var filePath: String = ""
    @State private var keyPath: String = ""
    @State private var isLoading = false

    
    var body: some View {
        ZStack {
            VStack(alignment: .center,spacing: 12) {
                Picker("", selection: $selectedMode) {
                    ForEach(Mode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(maxWidth: 300)
                .labelsHidden()
                .onChange(of: selectedMode) { _ in
                    filePath = ""
                    keyPath  = ""
                }
                VStack {
                    Picker("", selection: $selectedOption) {
                        ForEach(Options.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: 300)
                    .labelsHidden()
                    HStack {
                        TextField("Path to \(selectedMode == .decryption ? "decryption" : "encryption") file", text: $filePath)
                            .textFieldStyle(RoundedBorderTextFieldStyle()).frame(maxWidth:260).padding(2)
                        Button("...") {
                            selectFolder()
                        }.frame(maxWidth:35)
                    }
                    HStack {
                        TextField("Path to decryption key", text: $keyPath)
                            .textFieldStyle(RoundedBorderTextFieldStyle()).disabled(selectedMode != .decryption).frame(maxWidth:260).padding(2)
                        Button("...") {
                            selectKeyFile()
                        }.frame(maxWidth:35).disabled(selectedMode != .decryption)
                    }
                }
                
                Button(selectedMode == .decryption ? "Decrypt" : "Encrypt") {
                    startCrypto()
                }
                .frame(maxWidth: .infinity)
            }.disabled(isLoading)
                .padding(4)
            if isLoading {
                            VStack(spacing: 12) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.5, anchor: .center)
                            }
                            .frame(width: 150,height: 150)
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(.thinMaterial)          // zaokrąglone, rozmyte tło
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(radius: 10)
                            .transition(.opacity)
                            .zIndex(1)
                        }
        }.frame(width: 300, height: 200)
        
    }
    
    private func startCrypto() {
            isLoading = true
            let mode = selectedMode
            let option = selectedOption
            let path = filePath
            let key = keyPath

           DispatchQueue.global(qos: .userInitiated).async {
               let manager = CryptoManager(
                   mode: mode,
                   option: option,
                   filePath: path,
                   keyPath: key
               )
               manager.run()

               DispatchQueue.main.async {
                   isLoading = false
               }
           }
       }
    
    private func selectFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK {
            if let url = panel.url {
                filePath = url.path
            }
        }
    }
    
    private func selectKeyFile() {
          let panel = NSOpenPanel()
          panel.canChooseFiles = true
          panel.canChooseDirectories = false
          panel.allowsMultipleSelection = false
          panel.allowedContentTypes = [UTType(filenameExtension: "key")!]
        
          if panel.runModal() == .OK {
              if let url = panel.url {
                  keyPath = url.path
              }
          }
      }
}
