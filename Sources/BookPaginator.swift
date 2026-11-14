import UIKit

enum BookPaginator {
    static func paginate(_ sections: [(String, String)], width: CGFloat, height: CGFloat, fontSize: CGFloat) -> [(String, String)] {
        let usableWidth = max(120, width - 54)
        let usableHeight = max(180, height - 170)
        let font = UIFont(name: "Georgia", size: fontSize) ?? .systemFont(ofSize: fontSize)
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 8
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .paragraphStyle: paragraph]

        func fits(_ value: String) -> Bool {
            let rect = (value as NSString).boundingRect(
                with: CGSize(width: usableWidth, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: attributes,
                context: nil
            )
            return rect.height <= usableHeight
        }

        var result: [(String, String)] = []
        for (title, body) in sections {
            let words = body.split(whereSeparator: { $0.isWhitespace }).map(String.init)
            guard !words.isEmpty else { continue }
            var chunk = ""
            var continued = false
            for word in words {
                let candidate = chunk.isEmpty ? word : chunk + " " + word
                if fits(candidate) || chunk.isEmpty {
                    chunk = candidate
                } else {
                    result.append((continued ? title + " (continued)" : title, chunk))
                    continued = true
                    chunk = word
                }
            }
            if !chunk.isEmpty {
                result.append((continued ? title + " (continued)" : title, chunk))
            }
        }
        return result
    }
}
