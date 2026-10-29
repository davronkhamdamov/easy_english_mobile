import UIKit
import Flutter

// MARK: - iOS 26 Liquid Glass Tab Bar Controller
/// Native `UITabBarController` subclass that leverages Apple's iOS 26 Liquid Glass system.
///
/// On iOS 26+, `UITabBar` automatically adopts the Liquid Glass floating pill appearance.
/// This controller:
/// - Uses the modern `UITab` API (iOS 18+) for tab management
/// - Embeds `FlutterViewController` as an overlay covering the content area
/// - Creates transparent scroll-proxy VCs per tab for native minimize-on-scroll
/// - Supports `bottomAccessory` (iOS 26+), `UISearchTab` (iOS 18+), and adaptive layouts
/// - Falls back to `UITabBarAppearance` translucent styling on older iOS versions
final class LiquidGlassTabBarController: UITabBarController {

    // MARK: - Properties

    let flutterViewController: FlutterViewController

    /// Scroll proxies keyed by tab identifier, used for tab-bar minimization.
    private var scrollProxies: [String: UIScrollView] = [:]

    /// Ordered tab identifiers mirroring the current tab arrangement.
    private(set) var tabIdentifiers: [String] = []

    /// Weak reference to the bridge for sending events back to Flutter.
    weak var navigationBridge: LiquidGlassNavigationBridge?

    /// Guard to suppress onTabSelected echoes during programmatic selection.
    private var isProgrammaticSelection = false

    // MARK: - Initialisation

    init(flutterViewController: FlutterViewController) {
        self.flutterViewController = flutterViewController
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self

        // 1. Configure default tabs
        setupDefaultTabs()

        // 2. Embed Flutter view covering the full screen, below the tab bar
        embedFlutterView()

        // 3. Tab bar appearance
        configureTabBarAppearance()

        // 4. Tab bar minimisation on iOS 26+ (disabled per user requirement)
        if #available(iOS 26.0, *) {
            tabBarMinimizeBehavior = .never
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Guarantee the native tab bar always floats above the Flutter surface
        view.bringSubviewToFront(tabBar)

        // Notify Flutter about tab bar geometry changes
        sendTabBarGeometry()
    }

    // MARK: - Flutter View Embedding

    private func embedFlutterView() {
        addChild(flutterViewController)
        view.addSubview(flutterViewController.view)
        flutterViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            flutterViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            flutterViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            flutterViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            flutterViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        flutterViewController.didMove(toParent: self)
        view.bringSubviewToFront(tabBar)
    }

    // MARK: - Tab Bar Appearance

    private func configureTabBarAppearance() {
        if #available(iOS 26.0, *) {
            // iOS 26: Liquid Glass is applied automatically by the system.
            // Tint colour for the selected tab icon/label.
            tabBar.tintColor = .systemBlue
        } else {
            // Pre-iOS 26: translucent material fallback.
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            tabBar.standardAppearance = appearance
            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = appearance
            }
            tabBar.tintColor = .systemBlue
        }
    }

    // MARK: - Default Tabs

    private func setupDefaultTabs() {
        let defaults: [[String: Any]] = [
            ["id": "home",       "label": "Home",       "sfSymbolName": "house",                 "selectedSfSymbolName": "house.fill",                 "isSearch": false],
            ["id": "practice",   "label": "Practice",   "sfSymbolName": "doc.text",              "selectedSfSymbolName": "doc.text.fill",              "isSearch": false],
            ["id": "vocabulary", "label": "Vocabulary", "sfSymbolName": "character.book.closed", "selectedSfSymbolName": "character.book.closed.fill", "isSearch": false],
            ["id": "textlab",    "label": "Text Lab",   "sfSymbolName": "quote.bubble",          "selectedSfSymbolName": "quote.bubble.fill",          "isSearch": false],
            ["id": "profile",    "label": "Profile",    "sfSymbolName": "person",                "selectedSfSymbolName": "person.fill",                "isSearch": false],
        ]
        configureItems(defaults)
    }

    // MARK: - Public API: Configure Items

    /// Replaces all tabs with the given item descriptors.
    ///
    /// Each dictionary must contain:
    ///  - `id`                  : `String`
    ///  - `label`               : `String`
    ///  - `sfSymbolName`        : `String`
    ///  - `selectedSfSymbolName`: `String` (optional, defaults to sfSymbolName)
    ///  - `isSearch`            : `Bool`   (optional, defaults to false)
    func configureItems(_ items: [[String: Any]]) {
        scrollProxies.removeAll()
        tabIdentifiers = items.compactMap { $0["id"] as? String }

        if #available(iOS 18.0, *) {
            configureTabs_iOS18(items)
        } else {
            configureTabs_legacy(items)
        }

        // Re-ensure Flutter overlay is positioned correctly after tab setup
        ensureFlutterOverlay()
    }

    @available(iOS 18.0, *)
    private func configureTabs_iOS18(_ items: [[String: Any]]) {
        var uiTabs: [UITab] = []

        for item in items {
            let id           = item["id"] as? String ?? UUID().uuidString
            let label        = item["label"] as? String ?? ""
            let iconName     = item["sfSymbolName"] as? String ?? "circle"
            let isSearch     = item["isSearch"] as? Bool ?? false
            let image        = UIImage(systemName: iconName)

            if isSearch {
                let searchTab = UISearchTab { [weak self] _ in
                    return self?.createScrollProxyVC(for: id) ?? UIViewController()
                }
                searchTab.accessibilityLabel = label
                uiTabs.append(searchTab)
            } else {
                let tab = UITab(
                    title: label,
                    image: image,
                    identifier: id
                ) { [weak self] _ in
                    return self?.createScrollProxyVC(for: id) ?? UIViewController()
                }
                tab.accessibilityLabel = label
                uiTabs.append(tab)
            }
        }

        self.tabs = uiTabs
    }

    private func configureTabs_legacy(_ items: [[String: Any]]) {
        var vcs: [UIViewController] = []

        for item in items {
            let id               = item["id"] as? String ?? UUID().uuidString
            let label            = item["label"] as? String ?? ""
            let iconName         = item["sfSymbolName"] as? String ?? "circle"
            let selectedIconName = item["selectedSfSymbolName"] as? String ?? iconName

            let vc = createScrollProxyVC(for: id)
            vc.tabBarItem = UITabBarItem(
                title: label,
                image: UIImage(systemName: iconName),
                selectedImage: UIImage(systemName: selectedIconName)
            )
            vc.tabBarItem.accessibilityLabel = label
            vcs.append(vc)
        }

        self.viewControllers = vcs
    }

    // MARK: - Scroll Proxy View Controllers

    /// Creates a lightweight, transparent VC whose sole purpose is hosting a
    /// `UIScrollView` that the system watches for tab-bar minimisation.
    private func createScrollProxyVC(for identifier: String) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        vc.view.isUserInteractionEnabled = false

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        scrollView.isUserInteractionEnabled = false
        scrollView.contentSize = CGSize(width: 1, height: 2000)
        vc.view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: vc.view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
        ])

        scrollProxies[identifier] = scrollView

        if #available(iOS 15.0, *) {
            vc.setContentScrollView(scrollView, for: .bottom)
        }

        return vc
    }

    private func ensureFlutterOverlay() {
        guard flutterViewController.view.superview == self.view else { return }
        view.bringSubviewToFront(flutterViewController.view)
        view.bringSubviewToFront(tabBar)
    }

    // MARK: - Public API: Selection

    /// Programmatically selects the tab at `index` without echoing
    /// `onTabSelected` back to Flutter.
    func selectTab(at index: Int) {
        guard index >= 0 else { return }
        isProgrammaticSelection = true

        if #available(iOS 18.0, *) {
            if index < tabs.count {
                selectedTab = tabs[index]
            }
        } else {
            if index < (viewControllers?.count ?? 0) {
                selectedIndex = index
            }
        }

        isProgrammaticSelection = false
    }

    // MARK: - Public API: Scroll Integration

    /// Updates the content offset of the scroll proxy for the given (or current) tab,
    /// enabling the native tab-bar minimisation behaviour to respond to Flutter scroll.
    func updateScrollOffset(tabId: String?, offset: Double, contentHeight: Double, viewportHeight: Double) {
        let targetId = tabId ?? currentTabIdentifier
        guard let id = targetId, let scrollView = scrollProxies[id] else { return }

        let clampedHeight = max(contentHeight, viewportHeight + 1)
        scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: clampedHeight)
        scrollView.contentOffset = CGPoint(x: 0, y: max(0, offset))
    }

    // MARK: - Public API: Minimize Behaviour

    func setMinimizeBehavior(_ behavior: String) {
        if #available(iOS 26.0, *) {
            switch behavior {
            case "onScrollDown": tabBarMinimizeBehavior = .onScrollDown
            case "onScrollUp":   tabBarMinimizeBehavior = .onScrollUp
            case "never":        tabBarMinimizeBehavior = .never
            default:             tabBarMinimizeBehavior = .automatic
            }
        }
    }

    // MARK: - Public API: Bottom Accessory

    func setBottomAccessory(content: [String: Any]?) {
        if #available(iOS 26.0, *) {
            guard let content = content else {
                setBottomAccessory(nil, animated: true)
                return
            }

            let label = content["label"] as? String ?? ""

            let accessoryView = UIView()
            accessoryView.translatesAutoresizingMaskIntoConstraints = false

            let labelView = UILabel()
            labelView.text = label
            labelView.font = UIFont.preferredFont(forTextStyle: .subheadline)
            labelView.adjustsFontForContentSizeCategory = true
            labelView.textAlignment = .center
            labelView.translatesAutoresizingMaskIntoConstraints = false
            accessoryView.addSubview(labelView)

            NSLayoutConstraint.activate([
                labelView.leadingAnchor.constraint(equalTo: accessoryView.leadingAnchor, constant: 16),
                labelView.trailingAnchor.constraint(equalTo: accessoryView.trailingAnchor, constant: -16),
                labelView.topAnchor.constraint(equalTo: accessoryView.topAnchor, constant: 8),
                labelView.bottomAnchor.constraint(equalTo: accessoryView.bottomAnchor, constant: -8),
            ])

            let accessory = UITabAccessory(contentView: accessoryView)
            setBottomAccessory(accessory, animated: true)
        }
    }

    // MARK: - Public API: Visibility

    func setTabBarVisible(_ visible: Bool, animated: Bool) {
        if #available(iOS 18.0, *) {
            setTabBarHidden(!visible, animated: animated)
        } else {
            tabBar.isHidden = !visible
        }
    }

    // MARK: - Helpers

    private var currentTabIdentifier: String? {
        if #available(iOS 18.0, *) {
            return selectedTab?.identifier
        } else {
            let idx = selectedIndex
            return idx < tabIdentifiers.count ? tabIdentifiers[idx] : nil
        }
    }

    private func sendTabBarGeometry() {
        let frame = tabBar.frame
        navigationBridge?.onTabBarFrameChanged(
            x: Double(frame.origin.x),
            y: Double(frame.origin.y),
            width: Double(frame.width),
            height: Double(frame.height),
            bottomSafeArea: Double(view.safeAreaInsets.bottom)
        )
    }
}

// MARK: - UITabBarControllerDelegate

extension LiquidGlassTabBarController: UITabBarControllerDelegate {

    // Modern UITab delegate (iOS 18+)
    @available(iOS 18.0, *)
    func tabBarController(
        _ tabBarController: UITabBarController,
        didSelectTab selectedTab: UITab,
        previousTab: UITab?
    ) {
        guard !isProgrammaticSelection else { return }
        let index = tabs.firstIndex(where: { $0.identifier == selectedTab.identifier }) ?? 0
        navigationBridge?.onTabSelected(index: index)
    }

    // Legacy delegate (iOS < 18)
    func tabBarController(
        _ tabBarController: UITabBarController,
        didSelect viewController: UIViewController
    ) {
        // Only used on iOS < 18; on iOS 18+ the UITab-based delegate fires instead.
        if #unavailable(iOS 18.0) {
            guard !isProgrammaticSelection else { return }
            navigationBridge?.onTabSelected(index: selectedIndex)
        }
    }
}
