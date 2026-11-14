import Foundation
import WebKit

/// Loads the official publisher page on the user's device and extracts its visible reading
/// sections into memory. No lectionary text is bundled or redistributed in the IPA.
@MainActor
final class ReadingsLoader: NSObject, ObservableObject, WKNavigationDelegate {
    @Published var sections: [(String, String)] = []
    @Published var isLoading = false
    @Published var error: String?
    private var webView: WKWebView?

    func load(_ url: URL) {
        sections = []
        error = nil
        isLoading = true
        let web = WKWebView(frame: .zero)
        web.navigationDelegate = self
        webView = web
        web.load(URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30))
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let script = """
        (() => {
          const selectors = ['.field--name-body', '.field-name-body', 'article', 'main'];
          const root = selectors.map(s => document.querySelector(s)).find(Boolean);
          if (!root) return [];
          const blocks = [...root.querySelectorAll('h2,h3,h4,p')];
          let current = {title:'Sunday Readings', body:''};
          const out = [];
          for (const node of blocks) {
            if (node.closest('nav,header,footer,aside')) continue;
            const text = (node.innerText || '').trim();
            if (!text) continue;
            if (/^H[234]$/.test(node.tagName)) {
              if (current.body.trim()) out.push(current);
              current = {title:text,body:''};
            } else {
              current.body += (current.body ? '\\n\\n' : '') + text;
            }
          }
          if (current.body.trim()) out.push(current);
          return out;
        })()
        """
        webView.evaluateJavaScript(script) { [weak self] result, error in
            Task { @MainActor in
                guard let self else { return }
                self.isLoading = false
                if let error { self.error = error.localizedDescription; return }
                guard let raw = result as? [[String: String]] else {
                    self.error = "Unable to parse this reading page."
                    return
                }
                self.sections = raw.compactMap { item in
                    guard let title = item["title"], let body = item["body"], !body.isEmpty else { return nil }
                    return (title, body)
                }
                if self.sections.isEmpty {
                    self.error = "No readings were found. The publisher may have changed its page layout."
                }
            }
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.error = error.localizedDescription
        isLoading = false
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.error = error.localizedDescription
        isLoading = false
    }
}
