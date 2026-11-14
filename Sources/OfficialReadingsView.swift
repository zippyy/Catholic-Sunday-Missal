import SwiftUI
import WebKit

/// Displays the publisher's original page without copying or redistributing its text.
struct OfficialReadingsView: View {
    let url: URL
    let date: Date
    let onClose: () -> Void

    var body: some View {
        GeometryReader { geometry in
            let wide = geometry.size.width > 650
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    Button(action: onClose) {
                        Label("Book", systemImage: "chevron.left")
                    }
                    Spacer()
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(.headline, design: .serif))
                    Spacer()
                    ShareLink(item: url) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                .padding(.horizontal, 18)
                .frame(height: 54)
                .foregroundStyle(Color(red: 0.35, green: 0.22, blue: 0.13))
                .background(Color(red: 0.96, green: 0.92, blue: 0.81))

                HStack(spacing: 0) {
                    Spacer(minLength: wide ? 35 : 0)
                    USCCBWebReader(url: url)
                        .frame(maxWidth: wide ? 900 : .infinity)
                        .background(.white)
                    Spacer(minLength: wide ? 35 : 0)
                }
            }
            .background(Color(red: 0.38, green: 0.25, blue: 0.17))
        }
        .preferredColorScheme(.light)
    }
}

struct USCCBWebReader: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let web = WKWebView()
        web.isOpaque = false
        web.backgroundColor = .white
        web.scrollView.backgroundColor = .white
        web.allowsBackForwardNavigationGestures = true
        web.load(URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30))
        return web
    }

    func updateUIView(_ web: WKWebView, context: Context) {
        if web.url != url {
            web.load(URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30))
        }
    }
}
