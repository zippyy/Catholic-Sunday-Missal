import SwiftUI

@main
struct SundayMissalApp: App {
    var body: some Scene {
        WindowGroup {
            MissalReader().preferredColorScheme(.light)
        }
    }
}

struct MissalReader: View {
    @State private var sunday = 0
    @State private var page = 0
    @State private var fontSize: CGFloat = 19
    @State private var showContents = false
    @State private var cover = true
    private let leather = Color(red: 0.25, green: 0.12, blue: 0.105)
    private let gold = Color(red: 0.82, green: 0.68, blue: 0.44)
    private let calendar = Calendar(identifier: .gregorian)

    private var sundays: [Date] {
        let first = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1))!
        return (0..<365).compactMap { calendar.date(byAdding: .day, value: $0, to: first) }
            .filter { calendar.component(.weekday, from: $0) == 1 }
    }
    private var date: Date { sundays[sunday] }
    private var readingsURL: URL {
        let f = DateFormatter()
        f.dateFormat = "MMddyy"
        return URL(string: "https://bible.usccb.org/bible/readings/\(f.string(from: date)).cfm")!
    }
    private var pages: [(String, String)] {
        [
            ("Sunday Mass", "\(date.formatted(date: .complete, time: .omitted))\n\nThis independent companion follows the order of Sunday Mass. The official readings can be opened using the Readings link."),
            ("Introductory Rites", "Entrance\n\nSign of the Cross and Greeting\n\nPenitential Act\n\nKyrie\n\nGloria (when prescribed)\n\nCollect"),
            ("Liturgy of the Word", "First Reading\n\nResponsorial Psalm\n\nSecond Reading\n\nGospel Acclamation\n\nGospel\n\nHomily"),
            ("Profession of Faith", "Nicene Creed or Apostles' Creed (when prescribed)\n\nUniversal Prayer\n\nFor Scripture texts, use the official readings link."),
            ("Liturgy of the Eucharist", "Preparation of the Gifts\n\nPrayer over the Offerings\n\nEucharistic Prayer\n\nMemorial Acclamation\n\nGreat Amen"),
            ("Communion Rite", "The Lord's Prayer\n\nSign of Peace\n\nBreaking of the Bread\n\nCommunion\n\nPrayer after Communion"),
            ("Concluding Rites", "Blessing\n\nDismissal\n\nThe official U.S. Lectionary, Roman Missal, and Breaking Bread texts are not bundled in this prototype.")
        ]
    }
    var body: some View {
        GeometryReader { geometry in
            // Use available logical width, not device model, to determine facing pages.
            // On a two-panel device the app must span both displays to reach this width.
            let twoPage = geometry.size.width >= 580
            let step = twoPage ? 2 : 1
            VStack(spacing: 0) {
                HStack {
                    Button { showContents = true } label: { Image(systemName: "list.bullet") }
                    Text("SUNDAY MISSAL")
                        .font(.system(size: 18, weight: .semibold, design: .serif))
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                    Spacer()
                    Button { fontSize = max(14, fontSize - 2) } label: { Image(systemName: "textformat.size.smaller") }
                    Button { fontSize = min(30, fontSize + 2) } label: { Image(systemName: "textformat.size.larger") }
                    Button { cover = true } label: { Image(systemName: "book.closed") }
                }
                .padding(.horizontal, 15)
                .frame(height: 50)
                HStack {
                    Menu {
                        ForEach(sundays.indices, id: \.self) { i in
                            Button(sundays[i].formatted(date: .abbreviated, time: .omitted)) {
                                sunday = i
                                page = 0
                                cover = false
                            }
                        }
                    } label: { Label(date.formatted(.dateTime.month(.abbreviated).day().year()), systemImage: "calendar") }
                    Spacer()
                    Link(destination: readingsURL) { Label("Readings", systemImage: "book") }
                }
                .font(.system(size: 13, weight: .medium))
                .padding(.horizontal, 16)
                .frame(height: 42)

                GeometryReader { area in
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(leather)
                        if cover {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(LinearGradient(colors: [Color(red: 0.40, green: 0.22, blue: 0.17), leather], startPoint: .topLeading, endPoint: .bottomTrailing))
                                RoundedRectangle(cornerRadius: 6)
                                    .strokeBorder(gold, lineWidth: 2)
                                    .padding(17)
                                VStack(spacing: 25) {
                                    Image(systemName: "cross").font(.system(size: 45, weight: .ultraLight))
                                    Text("SUNDAY\nMISSAL")
                                        .font(.system(size: 38, weight: .semibold, design: .serif))
                                        .multilineTextAlignment(.center)
                                    Text("2026").font(.system(size: 27, design: .serif))
                                    Text("TAP TO OPEN").font(.caption).tracking(2)
                                }
                                .foregroundStyle(gold)
                            }
                            .padding(7)
                            .contentShape(Rectangle())
                            .onTapGesture { cover = false }
                        } else {
                            CurlBook(pages: pages, twoPage: twoPage, fontSize: fontSize, page: $page)
                                .id("\(twoPage)-\(fontSize)-\(sunday)")
                                .padding(7)
                        }
                    }
                    .shadow(color: .black.opacity(0.3), radius: 8, y: 3)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 4)
                }

                HStack {
                    Button { if cover { cover = false } else { page = max(0, page - step) } } label: { Label("Back", systemImage: "chevron.left") }
                        .disabled(!cover && page == 0)
                    Spacer()
                    Text(cover ? "COVER" : "\(page + 1) / \(pages.count)")
                        .font(.system(.caption, design: .serif))
                    Spacer()
                    Button { if cover { cover = false } else { page = min(pages.count - 1, page + step) } } label: { Label("Next", systemImage: "chevron.right") }
                        .disabled(!cover && page + step >= pages.count)
                }
                .font(.system(size: 14, weight: .semibold))
                .padding(.horizontal, 16)
                .frame(height: 50)
            }
            .foregroundStyle(gold)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(leather.ignoresSafeArea())
        }
        .sheet(isPresented: $showContents) {
            NavigationStack {
                List(pages.indices, id: \.self) { i in
                    Button(pages[i].0) {
                        page = i
                        cover = false
                        showContents = false
                    }
                }
                .navigationTitle("Contents")
                .toolbar { Button("Done") { showContents = false } }
            }
        }
    }
}
