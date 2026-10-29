import Flutter
import UIKit

// MARK: - Navigation Item Descriptor
struct IOS26NavItem {
    let id: String
    let label: String
    let sfSymbolName: String
    let selectedSfSymbolName: String
    let isSearch: Bool

    init(from dict: [String: Any]) {
        self.id = dict["id"] as? String ?? UUID().uuidString
        self.label = dict["label"] as? String ?? ""
        self.sfSymbolName = dict["sfSymbolName"] as? String ?? "circle"
        self.selectedSfSymbolName = dict["selectedSfSymbolName"] as? String ?? self.sfSymbolName
        self.isSearch = dict["isSearch"] as? Bool ?? false
    }
}

// MARK: - Native iOS 26 Liquid Glass Navigation Bar View
/// Faithfully reproduces Apple's official iOS 26 Liquid Glass Tab Bar design
/// (as documented in Apple's "Adopting Liquid Glass" & HIG Tab Bars guides).
///
/// Features:
/// 1. Floating main pill with native `UIGlassEffect(style: .regular)`
/// 2. Detached circular trailing search orb for `UISearchTab` / search items
/// 3. Animated glossy active tab capsule with specular bevel and tint
/// 4. Native SF Symbols with Dynamic Type typography
/// 5. Native haptics (`UISelectionFeedbackGenerator` / `UIImpactFeedbackGenerator`)
/// 6. Automatic minimize-on-scroll behavior
final class IOS26LiquidGlassNavBarView: UIView {

    // MARK: - Configuration & State
    var currentIndex: Int = 0 {
        didSet {
            updateSelection(animated: true)
        }
    }

    var onTabSelected: ((Int) -> Void)?
    var onFrameChanged: ((CGRect) -> Void)?

    private var items: [IOS26NavItem]
    private var isMinimized: Bool = false
    private var minimizeBehavior: String = "never"

    // Tint Color (e.g. System Purple as in Podcasts, or System Blue / App primary)
    var activeTintColor: UIColor = UIColor(red: 0.65, green: 0.35, blue: 0.95, alpha: 1.0) // Apple Podcasts purple / vibrant accent

    // UI Subviews: Main Pill
    private let mainPillContainer = UIView()
    private var mainGlassEffectView: UIVisualEffectView?
    private let activeCapsule = UIView()
    private var activeCapsuleGlass: UIVisualEffectView?
    private let tabStackView = UIStackView()
    private var tabButtons: [UIButton] = []
    private var iconViews: [UIImageView] = []
    private var labelViews: [UILabel] = []

    // UI Subviews: Detached Trailing Search Circle
    private let searchCircleContainer = UIView()
    private var searchGlassEffectView: UIVisualEffectView?
    private let searchButton = UIButton(type: .custom)
    private var searchIconView: UIImageView?
    private var searchItemIndex: Int?

    // Subviews: Optional Bottom Accessory (e.g. Mini Player)
    private let accessoryContainer = UIView()
    private var accessoryView: UIView?

    // Native Haptics
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let impactFeedback = UIImpactFeedbackGenerator(style: .light)

    // Layout
    private var pillHeightConstraint: NSLayoutConstraint?
    private var mainPillConstraints: [NSLayoutConstraint] = []
    private var searchCircleConstraints: [NSLayoutConstraint] = []
    private let standardHeight: CGFloat = 70.0
    private let minimizedHeight: CGFloat = 48.0
    private let pillCornerRadius: CGFloat = 35.0
    private let capsuleCornerRadius: CGFloat = 20.0

    // MARK: - Initialisation
    init(items: [IOS26NavItem], initialIndex: Int = 0) {
        self.items = items
        self.currentIndex = initialIndex
        super.init(frame: .zero)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup Views
    private func setupViews() {
        backgroundColor = .clear
        clipsToBounds = false

        // 1. Accessory Container (Floating above the tab bar if set)
        accessoryContainer.translatesAutoresizingMaskIntoConstraints = false
        accessoryContainer.backgroundColor = .clear
        accessoryContainer.isHidden = true
        addSubview(accessoryContainer)

        // 2. Main Pill Container
        mainPillContainer.translatesAutoresizingMaskIntoConstraints = false
        mainPillContainer.backgroundColor = .clear
        mainPillContainer.layer.cornerRadius = pillCornerRadius
        mainPillContainer.clipsToBounds = true

        // Liquid Glass background
        let mainGlass = createLiquidGlassEffectView()
        mainGlass.translatesAutoresizingMaskIntoConstraints = false
        mainGlass.layer.cornerRadius = pillCornerRadius
        mainGlass.clipsToBounds = true
        mainGlassEffectView = mainGlass
        mainPillContainer.addSubview(mainGlass)

        NSLayoutConstraint.activate([
            mainGlass.leadingAnchor.constraint(equalTo: mainPillContainer.leadingAnchor),
            mainGlass.trailingAnchor.constraint(equalTo: mainPillContainer.trailingAnchor),
            mainGlass.topAnchor.constraint(equalTo: mainPillContainer.topAnchor),
            mainGlass.bottomAnchor.constraint(equalTo: mainPillContainer.bottomAnchor),
        ])

        // Specular outer rim highlight (soft, natural glass edge)
        mainPillContainer.layer.borderWidth = 0.5
        mainPillContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.20).cgColor

        // 3. Active Tab Capsule (Elevated square-ish pod inside main pill)
        activeCapsule.backgroundColor = .clear
        activeCapsule.layer.cornerRadius = capsuleCornerRadius
        activeCapsule.clipsToBounds = true

        let capsuleGlass = createCapsuleGlassEffectView()
        capsuleGlass.translatesAutoresizingMaskIntoConstraints = false
        capsuleGlass.layer.cornerRadius = capsuleCornerRadius
        capsuleGlass.clipsToBounds = true
        activeCapsuleGlass = capsuleGlass
        activeCapsule.addSubview(capsuleGlass)

        NSLayoutConstraint.activate([
            capsuleGlass.leadingAnchor.constraint(equalTo: activeCapsule.leadingAnchor),
            capsuleGlass.trailingAnchor.constraint(equalTo: activeCapsule.trailingAnchor),
            capsuleGlass.topAnchor.constraint(equalTo: activeCapsule.topAnchor),
            capsuleGlass.bottomAnchor.constraint(equalTo: activeCapsule.bottomAnchor),
        ])

        // Subtle specular bevel border on the active capsule
        activeCapsule.layer.borderWidth = 0.5
        activeCapsule.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor

        // Tint wash over the active capsule
        let activeTintWash = UIView()
        activeTintWash.translatesAutoresizingMaskIntoConstraints = false
        activeTintWash.backgroundColor = activeTintColor.withAlphaComponent(0.12)
        activeTintWash.layer.cornerRadius = capsuleCornerRadius
        activeTintWash.isUserInteractionEnabled = false
        activeCapsule.addSubview(activeTintWash)

        NSLayoutConstraint.activate([
            activeTintWash.leadingAnchor.constraint(equalTo: activeCapsule.leadingAnchor),
            activeTintWash.trailingAnchor.constraint(equalTo: activeCapsule.trailingAnchor),
            activeTintWash.topAnchor.constraint(equalTo: activeCapsule.topAnchor),
            activeTintWash.bottomAnchor.constraint(equalTo: activeCapsule.bottomAnchor),
        ])

        mainPillContainer.addSubview(activeCapsule)

        // 4. Tab Stack View (inside main pill with 16pt horizontal padding so active capsule never touches outer curve)
        tabStackView.translatesAutoresizingMaskIntoConstraints = false
        tabStackView.axis = .horizontal
        tabStackView.distribution = .fillEqually
        tabStackView.alignment = .fill
        mainPillContainer.addSubview(tabStackView)

        NSLayoutConstraint.activate([
            tabStackView.leadingAnchor.constraint(equalTo: mainPillContainer.leadingAnchor, constant: 16),
            tabStackView.trailingAnchor.constraint(equalTo: mainPillContainer.trailingAnchor, constant: -16),
            tabStackView.topAnchor.constraint(equalTo: mainPillContainer.topAnchor, constant: 6),
            tabStackView.bottomAnchor.constraint(equalTo: mainPillContainer.bottomAnchor, constant: -6),
        ])

        // Enable Apple continuous smooth squircle corner curves (no sharp edges)
        mainPillContainer.layer.cornerCurve = .continuous
        activeCapsule.layer.cornerCurve = .continuous
        mainGlassEffectView?.layer.cornerCurve = .continuous

        addSubview(mainPillContainer)

        // 5. Detached Trailing Search Circle (only activated when search item is present)
        searchCircleContainer.translatesAutoresizingMaskIntoConstraints = false
        searchCircleContainer.backgroundColor = .clear
        searchCircleContainer.layer.cornerRadius = pillCornerRadius
        searchCircleContainer.layer.cornerCurve = .continuous
        searchCircleContainer.clipsToBounds = true

        let searchGlass = createLiquidGlassEffectView()
        searchGlass.translatesAutoresizingMaskIntoConstraints = false
        searchGlass.layer.cornerRadius = pillCornerRadius
        searchGlass.layer.cornerCurve = .continuous
        searchGlass.clipsToBounds = true
        searchGlassEffectView = searchGlass
        searchCircleContainer.addSubview(searchGlass)

        NSLayoutConstraint.activate([
            searchGlass.leadingAnchor.constraint(equalTo: searchCircleContainer.leadingAnchor),
            searchGlass.trailingAnchor.constraint(equalTo: searchCircleContainer.trailingAnchor),
            searchGlass.topAnchor.constraint(equalTo: searchCircleContainer.topAnchor),
            searchGlass.bottomAnchor.constraint(equalTo: searchCircleContainer.bottomAnchor),
        ])

        searchCircleContainer.layer.borderWidth = 0.5
        searchCircleContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.20).cgColor

        // Search Button inside Circle
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)

        let searchIcon = UIImage(
            systemName: "magnifyingglass",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 19, weight: .semibold)
        )
        let sIconView = UIImageView(image: searchIcon)
        sIconView.contentMode = .scaleAspectFit
        sIconView.tintColor = .white
        sIconView.translatesAutoresizingMaskIntoConstraints = false
        searchIconView = sIconView
        searchButton.addSubview(sIconView)

        NSLayoutConstraint.activate([
            sIconView.centerXAnchor.constraint(equalTo: searchButton.centerXAnchor),
            sIconView.centerYAnchor.constraint(equalTo: searchButton.centerYAnchor),
        ])

        searchCircleContainer.addSubview(searchButton)
        NSLayoutConstraint.activate([
            searchButton.leadingAnchor.constraint(equalTo: searchCircleContainer.leadingAnchor),
            searchButton.trailingAnchor.constraint(equalTo: searchCircleContainer.trailingAnchor),
            searchButton.topAnchor.constraint(equalTo: searchCircleContainer.topAnchor),
            searchButton.bottomAnchor.constraint(equalTo: searchCircleContainer.bottomAnchor),
        ])

        // 6. Layer Shadows
        applyShadow(to: mainPillContainer)
        applyShadow(to: searchCircleContainer)

        // 7. Auto Layout Constraints
        let heightConstraint = mainPillContainer.heightAnchor.constraint(equalToConstant: standardHeight)
        pillHeightConstraint = heightConstraint

        NSLayoutConstraint.activate([
            // Accessory Container
            accessoryContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            accessoryContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            accessoryContainer.topAnchor.constraint(equalTo: topAnchor),
            accessoryContainer.bottomAnchor.constraint(equalTo: mainPillContainer.topAnchor, constant: -10),
            heightConstraint,
        ])

        rebuildTabs()
    }

    private func applyShadow(to targetView: UIView) {
        targetView.layer.shadowColor = UIColor.black.cgColor
        targetView.layer.shadowOpacity = 0.22
        targetView.layer.shadowRadius = 16
        targetView.layer.shadowOffset = CGSize(width: 0, height: 6)
    }

    // MARK: - Native iOS 26 Liquid Glass Effects
    private func createLiquidGlassEffectView() -> UIVisualEffectView {
        if #available(iOS 26.0, *) {
            let glass = UIGlassEffect(style: .regular)
            glass.isInteractive = true
            return UIVisualEffectView(effect: glass)
        } else {
            let blur = UIBlurEffect(style: .systemThinMaterialDark)
            return UIVisualEffectView(effect: blur)
        }
    }

    private func createCapsuleGlassEffectView() -> UIVisualEffectView {
        if #available(iOS 26.0, *) {
            let glass = UIGlassEffect(style: .clear)
            glass.isInteractive = true
            return UIVisualEffectView(effect: glass)
        } else {
            let blur = UIBlurEffect(style: .systemUltraThinMaterialDark)
            return UIVisualEffectView(effect: blur)
        }
    }

    // MARK: - Rebuild Tabs
    private func rebuildTabs() {
        tabButtons.forEach { $0.removeFromSuperview() }
        tabButtons.removeAll()
        iconViews.removeAll()
        labelViews.removeAll()

        // Check if there is a dedicated Search tab
        searchItemIndex = items.firstIndex(where: { $0.isSearch || $0.label.lowercased() == "search" })
        let hasDetachedSearch = searchItemIndex != nil

        // Deactivate existing main pill & search circle constraints
        NSLayoutConstraint.deactivate(mainPillConstraints)
        NSLayoutConstraint.deactivate(searchCircleConstraints)
        mainPillConstraints.removeAll()
        searchCircleConstraints.removeAll()

        if hasDetachedSearch {
            if searchCircleContainer.superview == nil {
                addSubview(searchCircleContainer)
            }
            searchCircleContainer.isHidden = false

            let sConstraints = [
                searchCircleContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
                searchCircleContainer.topAnchor.constraint(equalTo: topAnchor),
                searchCircleContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
                searchCircleContainer.widthAnchor.constraint(equalToConstant: standardHeight),
            ]
            searchCircleConstraints = sConstraints
            NSLayoutConstraint.activate(sConstraints)

            let pConstraints = [
                mainPillContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
                mainPillContainer.trailingAnchor.constraint(equalTo: searchCircleContainer.leadingAnchor, constant: -10),
                mainPillContainer.topAnchor.constraint(equalTo: topAnchor),
                mainPillContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            ]
            mainPillConstraints = pConstraints
            NSLayoutConstraint.activate(pConstraints)
        } else {
            searchCircleContainer.removeFromSuperview()
            searchCircleContainer.isHidden = true

            let pConstraints = [
                mainPillContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
                mainPillContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
                mainPillContainer.topAnchor.constraint(equalTo: topAnchor),
                mainPillContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            ]
            mainPillConstraints = pConstraints
            NSLayoutConstraint.activate(pConstraints)
        }

        // Build main tab buttons
        for (index, item) in items.enumerated() {
            if hasDetachedSearch && index == searchItemIndex {
                continue // Displayed in the detached search circle
            }

            let button = createTabButton(for: item, index: index)
            tabButtons.append(button)
            tabStackView.addArrangedSubview(button)
        }

        updateSelection(animated: false)
    }

    private func createTabButton(for item: IOS26NavItem, index: Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.tag = index
        button.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
        button.accessibilityLabel = item.label

        let container = UIStackView()
        container.isUserInteractionEnabled = false
        container.axis = .vertical
        container.alignment = .center
        container.spacing = 3.5
        container.translatesAutoresizingMaskIntoConstraints = false

        let isSelected = index == currentIndex
        let iconName = isSelected ? item.selectedSfSymbolName : item.sfSymbolName
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 19, weight: isSelected ? .semibold : .medium)
        let icon = UIImage(systemName: iconName, withConfiguration: symbolConfig)

        let iconView = UIImageView(image: icon)
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = isSelected ? activeTintColor : UIColor(white: 0.9, alpha: 0.9)
        iconViews.append(iconView)

        let label = UILabel()
        label.text = item.label
        label.font = UIFont.systemFont(ofSize: 11, weight: isSelected ? .semibold : .medium)
        label.textColor = isSelected ? activeTintColor : UIColor(white: 0.9, alpha: 0.9)
        labelViews.append(label)

        container.addArrangedSubview(iconView)
        container.addArrangedSubview(label)

        button.addSubview(container)
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: button.centerYAnchor),
        ])

        return button
    }

    // MARK: - Selection Updates & Sliding Capsule Animation
    private func updateSelection(animated: Bool) {
        let hasDetachedSearch = searchItemIndex != nil

        for (buttonIndex, button) in tabButtons.enumerated() {
            let actualItemIndex = button.tag
            let isSelected = actualItemIndex == currentIndex
            let item = items[actualItemIndex]
            let iconName = isSelected ? item.selectedSfSymbolName : item.sfSymbolName
            let config = UIImage.SymbolConfiguration(pointSize: 19, weight: isSelected ? .semibold : .medium)

            if iconViews.indices.contains(buttonIndex) {
                iconViews[buttonIndex].image = UIImage(systemName: iconName, withConfiguration: config)
                iconViews[buttonIndex].tintColor = isSelected ? activeTintColor : UIColor(white: 0.9, alpha: 0.9)
            }
            if labelViews.indices.contains(buttonIndex) {
                labelViews[buttonIndex].textColor = isSelected ? activeTintColor : UIColor(white: 0.9, alpha: 0.9)
                labelViews[buttonIndex].font = UIFont.systemFont(ofSize: 11, weight: isSelected ? .semibold : .medium)
            }
        }

        // Highlight search circle if search is selected
        if hasDetachedSearch, let sIdx = searchItemIndex {
            let isSearchSelected = currentIndex == sIdx
            searchIconView?.tintColor = isSearchSelected ? activeTintColor : .white
            searchCircleContainer.layer.borderColor = isSearchSelected
                ? activeTintColor.withAlphaComponent(0.6).cgColor
                : UIColor.white.withAlphaComponent(0.28).cgColor
            activeCapsule.isHidden = isSearchSelected
        } else {
            activeCapsule.isHidden = false
        }

        updateCapsulePosition(animated: animated)
    }

    private func updateCapsulePosition(animated: Bool) {
        guard let selectedButton = tabButtons.first(where: { $0.tag == currentIndex }) else {
            return
        }

        let frameInPill = selectedButton.convert(selectedButton.bounds, to: mainPillContainer)
        guard frameInPill.width > 0 && frameInPill.height > 0 else { return }

        let capsuleFrame = CGRect(
            x: frameInPill.origin.x + 2.0,
            y: frameInPill.origin.y,
            width: frameInPill.width - 4.0,
            height: frameInPill.height
        )

        if animated {
            UIView.animate(
                withDuration: 0.36,
                delay: 0,
                usingSpringWithDamping: 0.76,
                initialSpringVelocity: 0.4,
                options: [.curveEaseOut, .beginFromCurrentState]
            ) {
                self.activeCapsule.frame = capsuleFrame
            }
        } else {
            activeCapsule.frame = capsuleFrame
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateCapsulePosition(animated: false)
        onFrameChanged?(self.frame)
    }

    // MARK: - Tap Actions
    @objc private func tabTapped(_ sender: UIButton) {
        let index = sender.tag
        guard index != currentIndex else { return }
        selectionFeedback.selectionChanged()
        currentIndex = index
        onTabSelected?(index)
    }

    @objc private func searchButtonTapped() {
        guard let sIdx = searchItemIndex else { return }
        impactFeedback.impactOccurred()
        currentIndex = sIdx
        onTabSelected?(sIdx)
    }

    // MARK: - Public Bridge APIs
    func configureItems(_ newItems: [IOS26NavItem]) {
        self.items = newItems
        if currentIndex >= newItems.count {
            currentIndex = 0
        }
        rebuildTabs()
    }

    func setMinimizeBehavior(_ behavior: String) {
        self.minimizeBehavior = behavior
    }

    func updateScrollOffset(offset: Double, contentHeight: Double, viewportHeight: Double) {
        // Disabled minimize-on-scroll: the bar stays completely stable at full height
        guard minimizeBehavior != "never" else { return }
    }

    func setBottomAccessory(label: String?) {
        accessoryView?.removeFromSuperview()
        accessoryView = nil

        guard let text = label, !text.isEmpty else {
            accessoryContainer.isHidden = true
            return
        }

        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.85)
        card.layer.cornerRadius = 14
        card.clipsToBounds = true

        let labelView = UILabel()
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.text = text
        labelView.font = UIFont.preferredFont(forTextStyle: .subheadline)
        labelView.textColor = .label
        labelView.textAlignment = .center
        card.addSubview(labelView)

        NSLayoutConstraint.activate([
            labelView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            labelView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            labelView.topAnchor.constraint(equalTo: card.topAnchor, constant: 8),
            labelView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -8),
        ])

        accessoryContainer.addSubview(card)
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: accessoryContainer.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: accessoryContainer.trailingAnchor),
            card.topAnchor.constraint(equalTo: accessoryContainer.topAnchor),
            card.bottomAnchor.constraint(equalTo: accessoryContainer.bottomAnchor),
        ])

        accessoryView = card
        accessoryContainer.isHidden = false
    }
}

// MARK: - Flutter Platform View Wrapper
final class IOS26LiquidGlassPlatformView: NSObject, FlutterPlatformView {
    private let navBarView: IOS26LiquidGlassNavBarView
    private let channel: FlutterMethodChannel

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        let channelName = "uz.cordialsoft.easyenglish/ios26_liquid_glass_nav_\(viewId)"
        self.channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)

        var navItems: [IOS26NavItem] = [
            IOS26NavItem(from: ["id": "home", "label": "Home", "sfSymbolName": "house", "selectedSfSymbolName": "house.fill"]),
            IOS26NavItem(from: ["id": "practice", "label": "Practice", "sfSymbolName": "doc.text", "selectedSfSymbolName": "doc.text.fill"]),
            IOS26NavItem(from: ["id": "textlab", "label": "Text Lab", "sfSymbolName": "quote.bubble", "selectedSfSymbolName": "quote.bubble.fill"]),
            IOS26NavItem(from: ["id": "profile", "label": "Profile", "sfSymbolName": "person", "selectedSfSymbolName": "person.fill"]),
        ]

        var initialIndex = 0
        if let dict = args as? [String: Any] {
            if let idx = dict["currentIndex"] as? Int {
                initialIndex = idx
            }
            if let rawItems = dict["items"] as? [[String: Any]] {
                let parsed = rawItems.map { IOS26NavItem(from: $0) }
                if !parsed.isEmpty {
                    navItems = parsed
                }
            }
        }

        self.navBarView = IOS26LiquidGlassNavBarView(items: navItems, initialIndex: initialIndex)
        super.init()

        navBarView.onTabSelected = { [weak self] index in
            self?.channel.invokeMethod("onTabSelected", arguments: ["index": index])
        }

        navBarView.onFrameChanged = { [weak self] frame in
            self?.channel.invokeMethod("onTabBarFrameChanged", arguments: [
                "x": Double(frame.origin.x),
                "y": Double(frame.origin.y),
                "width": Double(frame.size.width),
                "height": Double(frame.size.height),
                "bottomSafeArea": 34.0,
            ])
        }

        channel.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }
    }

    func view() -> UIView {
        return navBarView
    }

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setSelectedIndex":
            if let args = call.arguments as? [String: Any],
               let index = args["index"] as? Int {
                navBarView.currentIndex = index
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARG", message: "Index not found", details: nil))
            }

        case "configureItems":
            if let args = call.arguments as? [String: Any],
               let rawItems = args["items"] as? [[String: Any]] {
                let items = rawItems.map { IOS26NavItem(from: $0) }
                navBarView.configureItems(items)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARG", message: "Items not found", details: nil))
            }

        case "updateScrollOffset":
            if let args = call.arguments as? [String: Any],
               let offset = args["offset"] as? Double,
               let contentHeight = args["contentHeight"] as? Double,
               let viewportHeight = args["viewportHeight"] as? Double {
                navBarView.updateScrollOffset(offset: offset, contentHeight: contentHeight, viewportHeight: viewportHeight)
                result(nil)
            } else {
                result(nil)
            }

        case "setMinimizeBehavior":
            if let args = call.arguments as? [String: Any],
               let behavior = args["behavior"] as? String {
                navBarView.setMinimizeBehavior(behavior)
                result(nil)
            }
            result(nil)

        case "setBottomAccessory":
            if let args = call.arguments as? [String: Any] {
                let label = args["label"] as? String
                navBarView.setBottomAccessory(label: label)
            } else {
                navBarView.setBottomAccessory(label: nil)
            }
            result(nil)

        case "setTabBarVisible":
            if let args = call.arguments as? [String: Any],
               let visible = args["visible"] as? Bool {
                navBarView.isHidden = !visible
            }
            result(nil)

        case "getTabBarFrame":
            let frame = navBarView.frame
            result([
                "x": Double(frame.origin.x),
                "y": Double(frame.origin.y),
                "width": Double(frame.size.width),
                "height": Double(frame.size.height),
                "bottomSafeArea": 34.0,
            ])

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

// MARK: - Flutter Platform View Factory
final class IOS26LiquidGlassFactory: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return IOS26LiquidGlassPlatformView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger
        )
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
