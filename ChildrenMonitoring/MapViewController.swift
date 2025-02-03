import UIKit
import SwiftUI
import MapKit

struct ChatViewController: View {
    @State private var messageText = ""
    @State var messages: [String] = ["Hii"]
    @State private var showMapView = false
    
    var body: some View {
        VStack {
            HStack {
                Text("Chat")
                    .font(.largeTitle)
                    .bold()
                Image(systemName: "bubble.left.fill")
                    .font(.system(size: 26))
                    .foregroundColor(Color.blue)
                Spacer()
                Button(action: {
                    showMapView.toggle()
                }) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.blue)
                }
            }
            .padding()
            
            ScrollView {
                ForEach(messages, id: \.self) { message in
                    if message.contains("[USER]") {
                        let newMessage = message.replacingOccurrences(of: "[USER]", with: "")
                        HStack {
                            Spacer()
                            Text(newMessage)
                                .padding()
                                .foregroundColor(Color.white)
                                .background(Color.blue.opacity(0.8))
                                .cornerRadius(10)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 10)
                        }
                    } else {
                        HStack {
                            Text(message)
                                .padding()
                                .background(Color.gray.opacity(0.15))
                                .cornerRadius(10)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 10)
                            Spacer()
                        }
                    }
                }
                .rotationEffect(.degrees(180))
            }
            .rotationEffect(.degrees(180))
            .background(Color.gray.opacity(0.1))
            
            HStack {
                TextField("Type something", text: $messageText)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .onSubmit {
                        sendMessage(message: messageText)
                    }
                Button(action: {
                    sendMessage(message: messageText)
                }) {
                    Image(systemName: "paperplane.fill")
                }
                .font(.system(size: 26))
                .padding(.horizontal, 10)
            }
            .padding()
        }
        .sheet(isPresented: $showMapView) {
            MapViewControllerWrapper()
        }
    }
    
    func sendMessage(message: String) {
        withAnimation {
            messages.append("[USER]" + message)
            self.messageText = ""
        }
    }
}

struct MapViewController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let mapVC = UIViewController()
        let mapView = MKMapView()
        mapView.frame = mapVC.view.bounds
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapVC.view.addSubview(mapView)
        return mapVC
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct MapViewControllerWrapper: View {
    var body: some View {
        MapViewController()
            .edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ChatViewController()
    }
}
