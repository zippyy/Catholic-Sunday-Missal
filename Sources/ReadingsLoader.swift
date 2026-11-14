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
          const headings = /^(Reading (?:I|II|1|2)|First Reading|Second Reading|Responsorial Psalm|Gospel Acclamation|Alleluia|Verse Before the Gospel|Gospel|Sequence)$/i;
          const containers = [...document.querySelectorAll('.reading, .daily-reading, .field--name-field-readings, .field--name-body, article, main')];
          const root = containers.find(el => {
            const t = el.innerText || '';
            return /Reading (?:1|I)|Responsorial Psalm/i.test(t) && /Gospel/i.test(t);
          });
          if (!root) return [];
          // USCCB reading content may be nested in section containers.
          const nodes = [...root.querySelectorAll('h2,h3,h4,h5,p')];
          const result = [];
          let current = null;
          for (const node of nodes) {
            if (node.closest('nav,header,footer,aside,.breadcrumb,.share,.social-share,.views-element-container')) continue;
            const value = (node.innerText || '').replace(/\\u00a0/g,' ').trim();
            if (!value) continue;
            if (/^H[2-5]$/.test(node.tagName) && headings.test(value)) {
              if (current && current.body.trim()) result.push(current);
              current = {title:value, body:''};
              continue;
            }
            if (!current) continue;
            if (/^(Listen Podcast|View Reflection Video|View Calendar|Get Daily Readings|En Español|Share This)/i.test(value)) continue;
            if (/^(Reading (?:I|II|1|2)|Responsorial Psalm|Gospel Acclamation|Gospel)$/i.test(value)) continue;
            current.body += (current.body ? '\\n\\n' : '') + value;
          }
          if (current && current.body.trim()) result.push(current);
          return result;
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
