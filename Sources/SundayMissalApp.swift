import SwiftUI

@main
struct SundayMissalApp: App {
    var body: some Scene { WindowGroup { MissalBook() } }
}

struct MissalBook: View {
    @State private var selected = 0
    @State private var page = 0
    @State private var fontSize: CGFloat = 19
    private let calendar = Calendar(identifier: .gregorian)
    private var sundays: [Date] {
        let start = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1))!
        return (0..<365).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
            .filter { calendar.component(.weekday, from: $0) == 1 }
    }
    private var date: Date { sundays[selected] }
    private var readingsURL: URL {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMddyy"
        return URL(string: "https://bible.usccb.org/bible/readings/\(formatter.string(from: date)).cfm")!
    }
    private var pages: [(String, String)] {
        [
            (date.formatted(date: .complete, time: .omitted), "2026 Sunday Mass companion\n\nAn independent book-style reading guide. The official U.S. Lectionary and Roman Missal texts are not included."),
            ("Introductory Rites", "Entrance\n\nGreeting\n\nPenitential Act\n\nGloria (when prescribed)\n\nCollect"),
            ("Liturgy of the Word", "First Reading\n\nResponsorial Psalm\n\nSecond Reading\n\nGospel Acclamation\n\nGospel\n\nHomily"),
            ("Profession of Faith", "Creed (when prescribed)\n\nUniversal Prayer\n\nUse the Official Readings link above for the full readings for this Sunday."),
            ("Liturgy of the Eucharist", "Preparation of the Gifts\n\nPrayer over the Offerings\n\nEucharistic Prayer\n\nLord's Prayer\n\nSign of Peace"),
            ("Communion Rite", "Lamb of God\n\nCommunion\n\nPrayer after Communion"),
            ("Concluding Rites", "Announcements (if any)\n\nBlessing\n\nDismissal\n\nThis is not an official liturgical publication.")
        ]
    }
    var body: some View {
        GeometryReader { geometry in
            let spread = geometry.size.width >= 650
            VStack(spacing: 0) {
                HStack {
                    Text("SUNDAY MISSAL").font(.system(.headline, design: .serif)).tracking(1)
                    Spacer()
                    Button { fontSize = max(14, fontSize - 2) } label: { Image(systemName: "textformat.size.smaller") }
                    Button { fontSize = min(30, fontSize + 2) } label: { Image(systemName: "textformat.size.larger") }
                }
                .padding()
                .background(Color(red: 0.24, green: 0.16, blue: 0.13))
                .foregroundStyle(.white)
                HStack {
                    Picker("Sunday", selection: $selected) {
                        ForEach(sundays.indices, id: \.self) { index in
                            Text(sundays[index].formatted(date: .abbreviated, time: .omitted)).tag(index)
                        }
                    }
                    .onChange(of: selected) { _ in page = 0 }
                    Spacer()
                    Link("Official readings", destination: readingsURL)
                }
                .padding(.horizontal)
                HStack(spacing: 0) {
                    bookPage(page)
                    if spread {
                        Rectangle().fill(.brown.opacity(0.25)).frame(width: 3)
                        bookPage(page + 1)
                    }
                }
                .background(Color(red: 0.99, green: 0.97, blue: 0.91))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(8)
                .gesture(DragGesture(minimumDistance: 45).onEnded { value in
                    if value.translation.width < -45 { next(spread) }
                    if value.translation.width > 45 { previous(spread) }
                })
                HStack {
                    Button("Previous") { previous(spread) }.disabled(page == 0)
                    Spacer()
                    Text("\(min(page + 1, pages.count)) / \(pages.count)")
                    Spacer()
                    Button("Next") { next(spread) }.disabled(page + (spread ? 2 : 1) >= pages.count)
                }
                .padding()
            }
        }
    }
    private func next(_ spread: Bool) { page = min(max(0, pages.count - 1), page + (spread ? 2 : 1)) }
    private func previous(_ spread: Bool) { page = max(0, page - (spread ? 2 : 1)) }
    @ViewBuilder private func bookPage(_ index: Int) -> some View {
        if index < pages.count {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    Text(pages[index].0)
                        .font(.system(size: fontSize + 5, weight: .semibold, design: .serif))
                    Text(pages[index].1)
                        .font(.system(size: fontSize, design: .serif))
                        .lineSpacing(8)
                    Spacer(minLength: 30)
                    Text("Sunday Missal · 2026")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            Color(red: 0.99, green: 0.97, blue: 0.91).frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
