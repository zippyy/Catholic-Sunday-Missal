import SwiftUI

@main
struct SundayMissalApp: App {
    var body: some Scene {
        WindowGroup {
            MissalReader()
                .preferredColorScheme(.light)
                .statusBarHidden()
                .persistentSystemOverlays(.hidden)
        }
    }
}

enum ReaderSection: String, CaseIterable { case missal = "Missal", prayers = "Prayers", rosary = "Rosary" }

struct MissalReader: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @StateObject private var readings = ReadingsLoader()
    @State private var section: ReaderSection = .missal
    @State private var sunday = 0
    @State private var page = 0
    @State private var fontSize: CGFloat = 19
    @State private var showContents = false
    @State private var showDate = false
    @State private var showSettings = false
    @State private var showCover = false

    private let calendar = Calendar(identifier: .gregorian)
    private let gold = Color(red: 0.60, green: 0.39, blue: 0.14)
    private let leather = Color(red: 0.31, green: 0.23, blue: 0.19)

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
    private var sourceSections: [(String, String)] {
        switch section {
        case .prayers: return DevotionalContent.prayers
        case .rosary: return DevotionalContent.rosary
        case .missal: break
        }
        if readings.isLoading {
            return [("Loading Sunday Readings", "Retrieving the Scripture readings for \(date.formatted(date: .complete, time: .omitted))…")]
        }
        if let error = readings.error {
            return [("Readings Unavailable", "\(error)\n\nTap Retry in the toolbar to load the readings again.")]
        }
        if readings.sections.isEmpty {
            return [("Sunday Readings", "Select a Sunday to begin.")]
        }
        return [("Sunday Mass", date.formatted(date: .complete, time: .omitted))] + readings.sections
    }

    var body: some View {
        GeometryReader { geometry in
            let expanded = horizontalSizeClass == .regular && verticalSizeClass == .regular
            let landscape = geometry.size.width > geometry.size.height || expanded
            let facing = expanded && geometry.size.width >= 600
            let toolbarWidth: CGFloat = landscape ? 76 : 60
            let bookWidth = max(1, geometry.size.width - toolbarWidth - (landscape ? 38 : 12))
            let step = facing ? 2 : 1
            let contentWidth = max(160, (bookWidth - (facing ? 35 : 10)) / (facing ? 2 : 1))
            let bookPages = buildPages(width: contentWidth, height: geometry.size.height)
            let maxPage = max(0, bookPages.count - 1)

            HStack(spacing: landscape ? 16 : 5) {
                ZStack {
                    RoundedRectangle(cornerRadius: landscape ? 24 : 3)
                        .fill(leather)
                        .shadow(color: .black.opacity(0.4), radius: 10, y: 4)
                    if showCover {
                        coverView
                            .padding(10)
                            .onTapGesture { showCover = false }
                    } else {
                        CurlBook(pages: bookPages, twoPage: facing, fontSize: fontSize, page: $page)
                            .id("\(section.rawValue)-\(facing)-\(fontSize)-\(sunday)-\(readings.isLoading)-\(readings.sections.count)-\(readings.error ?? "")")
                            .padding(landscape ? 12 : 0)
                    }
                }
                .frame(width: bookWidth)
                .padding(.leading, landscape ? 18 : 0)
                VStack(spacing: 0) {
                    Spacer(minLength: 10)
                    tool("book.pages", label: "Contents") { showContents = true }
                    tool("cross", label: "Prayers") { switchTo(.prayers) }
                    tool("circle.hexagongrid", label: "Rosary") { switchTo(.rosary) }
                    tool("book.closed", label: "Missal") { switchTo(.missal) }
                    if section == .missal && readings.isLoading { ProgressView().tint(.brown) }
                    if section == .missal && readings.error != nil { tool("arrow.clockwise", label: "Retry") { readings.load(readingsURL) } }
                    if section == .missal { tool("calendar", label: "Sunday") { showDate = true } }
                    if section == .missal { tool("text.book.closed", label: "Readings") { page = min(1, maxPage); showCover = false } }
                    tool("textformat.size", label: "Text") { showSettings = true }
                    tool("chevron.left", label: "Back") { page = max(0, page - step); showCover = false }
                    tool("chevron.right", label: "Next") { page = min(maxPage, page + step); showCover = false }
                    tool("book.closed", label: "Cover") { showCover = true }
                    Spacer(minLength: 10)
                }
                .foregroundStyle(Color(red: 0.28, green: 0.20, blue: 0.14))
                .frame(width: toolbarWidth)
                .background(Color(red: 0.96, green: 0.92, blue: 0.81), in: RoundedRectangle(cornerRadius: 25))
                .padding(.trailing, landscape ? 12 : 4)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(
                LinearGradient(colors: [Color(red: 0.29, green: 0.18, blue: 0.12), Color(red: 0.45, green: 0.31, blue: 0.21), Color(red: 0.26, green: 0.17, blue: 0.12)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
            )
        }
        .ignoresSafeArea()
        .task(id: sunday) { readings.load(readingsURL) }
        .sheet(isPresented: $showContents) {
            NavigationStack {
                List(sourceSections.indices, id: \.self) { i in
                    Button(sourceSections[i].0) {
                        let prefix = Array(sourceSections.prefix(i))
                        let contentWidth: CGFloat = 350
                        page = BookPaginator.paginate(prefix, width: contentWidth, height: 700, fontSize: fontSize).count
                        showCover = false
                        showContents = false
                    }
                }
                .navigationTitle("Contents")
                .toolbar { Button("Done") { showContents = false } }
            }
        }
        .sheet(isPresented: $showDate) {
            NavigationStack {
                List(sundays.indices, id: \.self) { i in
                    Button(sundays[i].formatted(date: .complete, time: .omitted)) {
                        sunday = i
                        page = 0
                        showCover = false
                        showDate = false
                    }
                }
                .navigationTitle("2026 Sundays")
                .toolbar { Button("Done") { showDate = false } }
            }
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                VStack(spacing: 25) {
                    Text("Text size").font(.headline)
                    HStack {
                        Button("Smaller") { fontSize = max(14, fontSize - 2) }
                        Spacer()
                        Text("\(Int(fontSize)) pt")
                        Spacer()
                        Button("Larger") { fontSize = min(30, fontSize + 2) }
                    }
                    .padding()
                    Spacer()
                }
                .padding()
                .navigationTitle("Reading Settings")
                .toolbar { Button("Done") { showSettings = false } }
            }
            .presentationDetents([.medium])
        }
    }

    private func switchTo(_ next: ReaderSection) {
        section = next
        page = 0
        showCover = false
    }

    private func buildPages(width: CGFloat, height: CGFloat) -> [(String, String)] {
        BookPaginator.paginate(sourceSections, width: width, height: height, fontSize: fontSize)
    }

    private func tool(_ icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: icon).font(.system(size: 22))
                Text(label).font(.system(size: 10, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 11)
        }
    }

    private var coverView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.30, green: 0.12, blue: 0.10))
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(gold, lineWidth: 2)
                .padding(22)
            VStack(spacing: 25) {
                Image(systemName: "cross").font(.system(size: 45, weight: .ultraLight))
                Text("SUNDAY MISSAL")
                    .font(.system(size: 37, weight: .medium, design: .serif))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                Text("2026").font(.system(size: 25, design: .serif))
                Text("TAP TO OPEN").font(.caption).tracking(2)
            }
            .foregroundStyle(gold)
        }
    }
}
