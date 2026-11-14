import SwiftUI
import UIKit

/// Native UIKit page curl; mid-spine mode presents two facing pages.
struct CurlBook: UIViewControllerRepresentable {
    let pages: [(String, String)]
    let twoPage: Bool
    let fontSize: CGFloat
    @Binding var page: Int

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let spine: UIPageViewController.SpineLocation = twoPage ? .mid : .min
        let controller = UIPageViewController(
            transitionStyle: .pageCurl,
            navigationOrientation: .horizontal,
            options: [UIPageViewController.OptionsKey.spineLocation: NSNumber(value: spine.rawValue)]
        )
        controller.dataSource = context.coordinator
        controller.delegate = context.coordinator
        context.coordinator.controller = controller
        let start = twoPage ? (page / 2) * 2 : page
        let first = context.coordinator.makePage(start)
        let visible = twoPage ? [first, context.coordinator.makePage(start + 1)] : [first]
        controller.setViewControllers(visible, direction: .forward, animated: false)
        controller.view.backgroundColor = UIColor(red: 0.28, green: 0.15, blue: 0.12, alpha: 1)
        return controller
    }

    func updateUIViewController(_ controller: UIPageViewController, context: Context) {
        context.coordinator.parent = self
        let current = (controller.viewControllers?.first as? BookPageController)?.index ?? -1
        let desired = twoPage ? (page / 2) * 2 : page
        if current != desired {
            let first = context.coordinator.makePage(desired)
            let visible = twoPage ? [first, context.coordinator.makePage(desired + 1)] : [first]
            controller.setViewControllers(visible, direction: desired >= current ? .forward : .reverse, animated: false)
        }
    }

    final class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: CurlBook
        weak var controller: UIPageViewController?
        init(_ parent: CurlBook) { self.parent = parent }

        func makePage(_ index: Int) -> BookPageController {
            let item = index < parent.pages.count ? parent.pages[index] : ("", "")
            return BookPageController(index: index, title: item.0, content: item.1, fontSize: parent.fontSize, blank: index >= parent.pages.count)
        }
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let current = viewController as? BookPageController, current.index > 0 else { return nil }
            return makePage(current.index - 1)
        }
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let current = viewController as? BookPageController, current.index + 1 < parent.pages.count + (parent.twoPage ? 1 : 0) else { return nil }
            return makePage(current.index + 1)
        }
        func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            guard completed, let current = pageViewController.viewControllers?.first as? BookPageController else { return }
            parent.page = current.index
        }
        func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewController.SpineLocation {
            return parent.twoPage ? .mid : .min
        }
    }
}

final class BookPageController: UIViewController {
    let index: Int
    let pageTitle: String
    let content: String
    let fontSize: CGFloat
    let blank: Bool

    init(index: Int, title: String, content: String, fontSize: CGFloat, blank: Bool) {
        self.index = index
        self.pageTitle = title
        self.content = content
        self.fontSize = fontSize
        self.blank = blank
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() {
        let paper = UIColor(red: 0.98, green: 0.956, blue: 0.89, alpha: 1)
        let ink = UIColor(red: 0.21, green: 0.16, blue: 0.13, alpha: 1)
        let root = UIView()
        root.backgroundColor = paper
        view = root
        guard !blank else { return }

        let scroll = UIScrollView()
        scroll.isScrollEnabled = false
        scroll.showsVerticalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        root.addSubview(scroll)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: root.topAnchor),
            scroll.bottomAnchor.constraint(equalTo: root.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: root.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: root.trailingAnchor)
        ])

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 22
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 30),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -28),
            stack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor, constant: 25),
            stack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor, constant: -25),
            stack.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor, constant: -50)
        ])

        func label(_ text: String, size: CGFloat, bold: Bool = false) -> UILabel {
            let result = UILabel()
            result.numberOfLines = 0
            result.textColor = ink
            result.font = bold ? UIFont(name: "Georgia-Bold", size: size) ?? .boldSystemFont(ofSize: size) : UIFont(name: "Georgia", size: size) ?? .systemFont(ofSize: size)
            result.text = text
            return result
        }
        let heading = label("THE HOLY MASS", size: 11, bold: true)
        heading.textAlignment = .center
        stack.addArrangedSubview(heading)

        let separator = UIView()
        separator.backgroundColor = UIColor(red: 0.75, green: 0.61, blue: 0.37, alpha: 1)
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        stack.addArrangedSubview(separator)

        stack.addArrangedSubview(label(pageTitle, size: fontSize + 6, bold: true))
        let body = label(content, size: fontSize)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 8
        body.attributedText = NSAttributedString(string: content, attributes: [.paragraphStyle: style, .font: body.font!, .foregroundColor: ink])
        stack.addArrangedSubview(body)
        let pageNumber = label("\(index + 1)", size: 12)
        pageNumber.textAlignment = .center
        stack.addArrangedSubview(pageNumber)
    }
}
