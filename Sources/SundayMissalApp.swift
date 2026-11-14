import SwiftUI

private enum BookPalette {
    static let leather = Color(red: 0.25, green: 0.12, blue: 0.105)
    static let leatherLight = Color(red: 0.43, green: 0.25, blue: 0.19)
    static let paper = Color(red: 0.98, green: 0.955, blue: 0.875)
    static let ink = Color(red: 0.21, green: 0.16, blue: 0.13)
    static let gold = Color(red: 0.79, green: 0.65, blue: 0.40)
}

@main
struct SundayMissalApp: App {
    var body: some Scene {
        WindowGroup {
            SundayMissalView()
                .preferredColorScheme(.light)
        }
    }
}

private struct MissalPage: Identifiable {
    let id: Int
    let title: String
    let body: String
}

struct SundayMissalView: View {
    @State private var selectedSunday = 0
    @State private var currentPage = 0
    @State private var textSize: CGFloat = 19
    @State private var showContents = false
    @State private var showCover = true

    private let calendar = Calendar(identifier: .gregorian)

    private var sundays: [Date] {
        let start = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1))!
        return (0..<365).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
            .filter { calendar.component(.weekday, from: $0) == 1 }
    }

    private var date: Date { sundays[selectedSunday] }

    private var readingURL: URL {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMddyy"
        return URL(string: "https://bible.usccb.org/bible/readings/\(formatter.string(from: date)).cfm")!
    }

    private var pages: [MissalPage] {
        [
            .init(id: 0, title: "Sunday Mass", body: "\(date.formatted(date: .complete, time: .omitted))\n\nA companion for following the celebration of Mass. Select Official Readings to read the Scripture passages for this Sunday."),
            .init(id: 1, title: "Introductory Rites", body: "Entrance\n\nSign of the Cross and Greeting\n\nPenitential Act\n\nKyrie\n\nGloria (when prescribed)\n\nCollect"),
            .init(id: 2, title: "Liturgy of the Word", body: "First Reading\n\nResponsorial Psalm\n\nSecond Reading\n\nGospel Acclamation\n\nGospel\n\nHomily"),
            .init(id: 3, title: "Profession of Faith", body: "Nicene Creed or Apostles' Creed (when prescribed)\n\nUniversal Prayer\n\nThe Scripture texts are available from the Official Readings link."),
            .init(id: 4, title: "Liturgy of the Eucharist", body: "Preparation of the Gifts\n\nPrayer over the Offerings\n\nEucharistic Prayer\n\nMemorial Acclamation\n\nGreat Amen"),
            .init(id: 5, title: "Communion Rite", body: "The Lord's Prayer\n\nSign of Peace\n\nBreaking of the Bread\n\nCommunion\n\nPrayer after Communion"),
            .init(id: 6, title: "Concluding Rites", body: "Blessing\n\nDismissal\n\nThis independent prototype does not reproduce the official Roman Missal, U.S. Lectionary, or Breaking Bread. Full licensed texts are not yet included.")
        ]
    }

    var body: some View {
        GeometryReader { outer in
            let spread = outer.size.width >= 700
            let horizontalInset: CGFloat = spread ? 20 : 8
            let availableWidth = max(1, outer.size.width - horizontalInset * 2)
            VStack(spacing: 0) {
                topBar
                HStack(spacing: 12) {
                    Menu {
                        ForEach(sundays.indices, id: \.self) { index in
                            Button(sundays[index].formatted(date: .abbreviated, time: .omitted)) {
                                selectedSunday = index
                                currentPage = 0
                                showCover = false
                            }
                        }
                    } label: {
                        Label(date.formatted(.dateTime.month(.abbreviated).day().year()), systemImage: "calendar")
                            .lineLimit(1)
                    }
                    Spacer(minLength: 4)
                    Link(destination: readingURL) {
                        Label("Readings", systemImage: "book.closed")
                            .lineLimit(1)
                    }
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(BookPalette.gold)
                .padding(.horizontal, 18)
                .frame(height: 48)

                GeometryReader { bookArea in
                    let bookHeight = max(1, bookArea.size.height - 12)
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(BookPalette.leather)
                            .shadow(color: .black.opacity(0.5), radius: 12, y: 5)
                        if showCover {
                            cover
                                .padding(9)
                                .contentShape(Rectangle())
                                .onTapGesture { showCover = false }
                        } else {
                            HStack(spacing: 0) {
                                pageView(currentPage, isLeft: spread)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                if spread {
                                    Rectangle()
                                        .fill(LinearGradient(colors: [.black.opacity(0.25), .brown.opacity(0.15), .black.opacity(0.15)], startPoint: .leading, endPoint: .trailing))
                                        .frame(width: 9)
                                    pageView(currentPage + 1, isLeft: false)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                }
                            }
                            .padding(7)
                        }
                    }
                    .frame(width: availableWidth, height: bookHeight)
                    .position(x: bookArea.size.width / 2, y: bookArea.size.height / 2)
                    .gesture(DragGesture(minimumDistance: 35).onEnded { gesture in
                        if showCover {
                            showCover = false
                        } else if gesture.translation.width < -35 {
                            next(spread)
                        } else if gesture.translation.width > 35 {
                            previous(spread)
                        }
                    })
                }

                HStack(spacing: 12) {
                    Button {
                        if showCover { showCover = false } else { previous(spread) }
                    } label: { Label("Back", systemImage: "chevron.left") }
                    .disabled(!showCover && currentPage == 0)

                    Spacer()
                    Text(showCover ? "COVER" : "\(min(currentPage + 1, pages.count))–\(min(currentPage + (spread ? 2 : 1), pages.count)) / \(pages.count)")
                        .font(.system(.caption, design: .serif))
                        .tracking(1.5)
                    Spacer()

                    Button {
                        if showCover { showCover = false } else { next(spread) }
                    } label: { Label("Next", systemImage: "chevron.right") }
                    .disabled(!showCover && currentPage + (spread ? 2 : 1) >= pages.count)
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(BookPalette.gold)
                .padding(.horizontal, 20)
                .frame(height: 55)
            }
            .frame(width: outer.size.width, height: outer.size.height)
            .background(BookPalette.leather.ignoresSafeArea())
        }
        .sheet(isPresented: $showContents) {
            NavigationStack {
                List(pages) { page in
                    Button(page.title) {
                        currentPage = page.id
                        showCover = false
                        showContents = false
                    }
                }
                .navigationTitle("Contents")
                .toolbar { Button("Done") { showContents = false } }
            }
        }
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            Button { showContents = true } label: {
                Image(systemName: "list.bullet")
                    .font(.system(size: 19, weight: .medium))
            }
            Text("SUNDAY MISSAL")
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .tracking(1.3)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer(minLength: 0)
            Button { textSize = max(14, textSize - 2) } label: {
                Image(systemName: "textformat.size.smaller")
            }
            Button { textSize = min(30, textSize + 2) } label: {
                Image(systemName: "textformat.size.larger")
            }
            Button { showCover = true } label: {
                Image(systemName: "book.closed")
            }
        }
        .foregroundStyle(BookPalette.gold)
        .padding(.horizontal, 18)
        .frame(height: 56)
        .background(BookPalette.leatherLight.opacity(0.5))
    }

    private var cover: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 9)
                .fill(LinearGradient(colors: [BookPalette.leatherLight, BookPalette.leather, BookPalette.leatherLight.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing))
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(BookPalette.gold.opacity(0.8), lineWidth: 2)
                .padding(18)
            VStack(spacing: 22) {
                Image(systemName: "cross")
                    .font(.system(size: 43, weight: .ultraLight))
                Text("SUNDAY\nMISSAL")
                    .font(.system(size: 36, weight: .medium, design: .serif))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.7)
                Rectangle().frame(width: 90, height: 1)
                Text("2026")
                    .font(.system(size: 25, design: .serif))
                Text("TAP TO OPEN")
                    .font(.caption2)
                    .tracking(3)
                    .padding(.top, 35)
            }
            .foregroundStyle(BookPalette.gold)
        }
        .accessibilityLabel("Sunday Missal 2026. Tap to open the book.")
    }

    @ViewBuilder
    private func pageView(_ index: Int, isLeft: Bool) -> some View {
        if index < pages.count {
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("THE HOLY MASS")
                            .font(.system(size: 10, weight: .medium, design: .serif))
                            .tracking(2.2)
                            .frame(maxWidth: .infinity)
                        Rectangle()
                            .fill(BookPalette.gold.opacity(0.65))
                            .frame(height: 1)
                        Text(pages[index].title)
                            .font(.system(size: textSize + 5, weight: .semibold, design: .serif))
                            .fixedSize(horizontal: false, vertical: true)
                        Text(pages[index].body)
                            .font(.system(size: textSize, design: .serif))
                            .lineSpacing(7)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 25)
                        Text("\(index + 1)")
                            .font(.system(size: 12, design: .serif))
                            .frame(maxWidth: .infinity)
                    }
                    .foregroundStyle(BookPalette.ink)
                    .padding(.horizontal, geometry.size.width < 300 ? 17 : 26)
                    .padding(.vertical, 24)
                    .frame(maxWidth: .infinity, minHeight: geometry.size.height, alignment: .topLeading)
                }
                .background(
                    LinearGradient(colors: isLeft ? [BookPalette.paper, Color(red: 0.93, green: 0.89, blue: 0.79)] : [Color(red: 0.93, green: 0.89, blue: 0.79), BookPalette.paper],
                                   startPoint: .leading, endPoint: .trailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 3))
            }
        } else {
            BookPalette.paper
        }
    }

    private func next(_ spread: Bool) {
        currentPage = min(pages.count - 1, currentPage + (spread ? 2 : 1))
    }

    private func previous(_ spread: Bool) {
        currentPage = max(0, currentPage - (spread ? 2 : 1))
    }
}
