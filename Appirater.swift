import Foundation
import StoreKit
import SystemConfiguration
import UIKit

final class Appirater: NSObject, SKStoreProductViewControllerDelegate {
    static let kAppiraterFirstUseDate = "kAppiraterFirstUseDate"
    static let kAppiraterUseCount = "kAppiraterUseCount"
    static let kAppiraterSignificantEventCount = "kAppiraterSignificantEventCount"
    static let kAppiraterCurrentVersion = "kAppiraterCurrentVersion"
    static let kAppiraterRatedCurrentVersion = "kAppiraterRatedCurrentVersion"
    static let kAppiraterDeclinedToRate = "kAppiraterDeclinedToRate"
    static let kAppiraterReminderRequestDate = "kAppiraterReminderRequestDate"

    private static let templateReviewURL = "itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=APP_ID"
    private static let templateReviewURLiOS7 = "itms-apps://itunes.apple.com/app/idAPP_ID"
    private static let templateReviewURLiOS8 = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=APP_ID&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"

    private static var appId: String = ""
    private static var daysUntilPrompt: Double = 30
    private static var usesUntilPrompt: Int = 20
    private static var significantEventsUntilPrompt: Int = -1
    private static var timeBeforeReminding: Double = 1
    private static var debug: Bool = false
    private static weak var delegate: AppiraterDelegate?
    private static var usesAnimation: Bool = true
    private static var modalOpen: Bool = false
    private static var alwaysUseMainBundle: Bool = false

    private var ratingAlert: UIAlertController?
    private var openInAppStore: Bool = true

    private var alertTitle: String?
    private var alertMessage: String?
    private var alertCancelTitle: String?
    private var alertRateTitle: String?
    private var alertRateLaterTitle: String?

    private override init() {
        super.init()
        if let systemVersion = Double(UIDevice.current.systemVersion) {
            openInAppStore = systemVersion >= 7.0
        }
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Public configuration

    static func setAppId(_ appId: String) {
        Self.appId = appId
    }

    static func setDaysUntilPrompt(_ value: Double) {
        daysUntilPrompt = value
    }

    static func setUsesUntilPrompt(_ value: Int) {
        usesUntilPrompt = value
    }

    static func setSignificantEventsUntilPrompt(_ value: Int) {
        significantEventsUntilPrompt = value
    }

    static func setTimeBeforeReminding(_ value: Double) {
        timeBeforeReminding = value
    }

    static func setCustomAlertTitle(_ title: String) {
        shared.alertTitle = title
    }

    static func setCustomAlertMessage(_ message: String) {
        shared.alertMessage = message
    }

    static func setCustomAlertCancelButtonTitle(_ cancelTitle: String) {
        shared.alertCancelTitle = cancelTitle
    }

    static func setCustomAlertRateButtonTitle(_ rateTitle: String) {
        shared.alertRateTitle = rateTitle
    }

    static func setCustomAlertRateLaterButtonTitle(_ rateLaterTitle: String) {
        shared.alertRateLaterTitle = rateLaterTitle
    }

    static func setDebug(_ debug: Bool) {
        Self.debug = debug
    }

    static func setDelegate(_ delegate: AppiraterDelegate?) {
        Self.delegate = delegate
    }

    static func setUsesAnimation(_ animation: Bool) {
        usesAnimation = animation
    }

    static func setOpenInAppStore(_ openInAppStore: Bool) {
        shared.openInAppStore = openInAppStore
    }

    static func setAlwaysUseMainBundle(_ useMainBundle: Bool) {
        alwaysUseMainBundle = useMainBundle
    }

    // MARK: - Public API

    static func appLaunched(_ canPromptForRating: Bool) {
        DispatchQueue.global(qos: .background).async {
            shared.incrementAndRate(canPromptForRating)
        }
    }

    static func appEnteredForeground(_ canPromptForRating: Bool) {
        DispatchQueue.global(qos: .background).async {
            shared.incrementAndRate(canPromptForRating)
        }
    }

    static func userDidSignificantEvent(_ canPromptForRating: Bool) {
        DispatchQueue.global(qos: .background).async {
            shared.incrementSignificantEventAndRate(canPromptForRating)
        }
    }

    static func tryToShowPrompt() {
        shared.showPromptWithChecks(true, displayRateLaterButton: true)
    }

    static func forceShowPrompt(_ displayRateLaterButton: Bool) {
        shared.showPromptWithChecks(false, displayRateLaterButton: displayRateLaterButton)
    }

    static func rateApp() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: kAppiraterRatedCurrentVersion)
        userDefaults.synchronize()

        if !shared.openInAppStore, #available(iOS 6.0, *) {
            let storeViewController = SKStoreProductViewController()
            let appIdNumber = NSNumber(value: Int(appId) ?? 0)
            storeViewController.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: appIdNumber], completionBlock: nil)
            storeViewController.delegate = shared

            if let delegate = delegate {
                delegate.appiraterWillPresentModalView?(shared, animated: usesAnimation)
            }

            if let presenter = getRootViewController() {
                presenter.present(storeViewController, animated: usesAnimation) {
                    modalOpen = true
                }
            }
        } else {
#if targetEnvironment(simulator)
            if debug {
                print("APPIRATER NOTE: iTunes App Store is not supported on the iOS simulator. Unable to open App Store page.")
            }
#else
            var reviewURL = templateReviewURL.replacingOccurrences(of: "APP_ID", with: appId)
            if let systemVersion = Double(UIDevice.current.systemVersion), systemVersion >= 7.0, systemVersion < 8.0 {
                reviewURL = templateReviewURLiOS7.replacingOccurrences(of: "APP_ID", with: appId)
            } else if let systemVersion = Double(UIDevice.current.systemVersion), systemVersion >= 8.0 {
                reviewURL = templateReviewURLiOS8.replacingOccurrences(of: "APP_ID", with: appId)
            }
            if let url = URL(string: reviewURL) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
#endif
        }
    }

    static func closeModal() {
        if modalOpen {
            modalOpen = false
            if let presenter = UIApplication.shared.keyWindow?.rootViewController {
                let topController = topMostViewController(presenter)
                topController.dismiss(animated: usesAnimation) {
                    if let delegate = delegate {
                        delegate.appiraterDidDismissModalView?(shared, animated: usesAnimation)
                    }
                }
            }
        }
    }

    func userHasDeclinedToRate() -> Bool {
        UserDefaults.standard.bool(forKey: Self.kAppiraterDeclinedToRate)
    }

    func userHasRatedCurrentVersion() -> Bool {
        UserDefaults.standard.bool(forKey: Self.kAppiraterRatedCurrentVersion)
    }

    // MARK: - Private

    private static var shared: Appirater {
        struct Holder {
            static let instance = Appirater()
        }
        return Holder.instance
    }

    private static func bundle() -> Bundle {
        if alwaysUseMainBundle {
            return Bundle.main
        }

        if let bundleURL = Bundle.main.url(forResource: "Appirater", withExtension: "bundle"),
           let bundle = Bundle(url: bundleURL) {
            return bundle
        }

        return Bundle.main
    }

    private var resolvedAlertTitle: String {
        if let alertTitle { return alertTitle }
        let localized = NSLocalizedString("Rate %@", tableName: "AppiraterLocalizable", bundle: Self.bundle(), comment: "")
        let appName = Appirater.appName()
        return String(format: localized, appName)
    }

    private var resolvedAlertMessage: String {
        if let alertMessage { return alertMessage }
        let localized = NSLocalizedString("If you enjoy using %@, would you mind taking a moment to rate it? It won't take more than a minute. Thanks for your support!", tableName: "AppiraterLocalizable", bundle: Self.bundle(), comment: "")
        let appName = Appirater.appName()
        return String(format: localized, appName)
    }

    private var resolvedAlertCancelTitle: String {
        alertCancelTitle ?? NSLocalizedString("No, Thanks", tableName: "AppiraterLocalizable", bundle: Self.bundle(), comment: "")
    }

    private var resolvedAlertRateTitle: String {
        if let alertRateTitle { return alertRateTitle }
        let localized = NSLocalizedString("Rate %@", tableName: "AppiraterLocalizable", bundle: Self.bundle(), comment: "")
        let appName = Appirater.appName()
        return String(format: localized, appName)
    }

    private var resolvedAlertRateLaterTitle: String {
        alertRateLaterTitle ?? NSLocalizedString("Remind me later", tableName: "AppiraterLocalizable", bundle: Self.bundle(), comment: "")
    }

    private static func appName() -> String {
        let info = Bundle.main.localizedInfoDictionary
        if let name = info?["CFBundleDisplayName"] as? String {
            return name
        }
        let mainInfo = Bundle.main.infoDictionary
        if let name = mainInfo?["CFBundleDisplayName"] as? String {
            return name
        }
        if let name = mainInfo?["CFBundleName"] as? String {
            return name
        }
        return ""
    }

    @objc private func appWillResignActive() {
        hideRatingAlert()
    }

    private func showRatingAlert(_ displayRateLaterButton: Bool = true) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: self.resolvedAlertTitle, message: self.resolvedAlertMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: self.resolvedAlertCancelTitle, style: .cancel, handler: { _ in
                let userDefaults = UserDefaults.standard
                userDefaults.set(true, forKey: Self.kAppiraterDeclinedToRate)
                userDefaults.synchronize()
                if let delegate = Self.delegate {
                    delegate.appiraterDidDeclineToRate?(self)
                }
            }))
            alert.addAction(UIAlertAction(title: self.resolvedAlertRateTitle, style: .default, handler: { _ in
                Appirater.rateApp()
                if let delegate = Self.delegate {
                    delegate.appiraterDidOptToRate?(self)
                }
            }))
            if displayRateLaterButton {
                alert.addAction(UIAlertAction(title: self.resolvedAlertRateLaterTitle, style: .default, handler: { _ in
                    let userDefaults = UserDefaults.standard
                    userDefaults.set(Date().timeIntervalSince1970, forKey: Self.kAppiraterReminderRequestDate)
                    userDefaults.synchronize()
                    if let delegate = Self.delegate {
                        delegate.appiraterDidOptToRemindLater?(self)
                    }
                }))
            }

            self.ratingAlert = alert
            if let presenter = Appirater.getRootViewController() {
                presenter.present(alert, animated: true, completion: nil)
                if let delegate = Self.delegate {
                    delegate.appiraterDidDisplayAlert?(self)
                }
            }
        }
    }

    private func hideRatingAlert() {
        if let alert = ratingAlert, alert.presentingViewController != nil {
            alert.dismiss(animated: false, completion: nil)
        }
    }

    private func showPromptWithChecks(_ withChecks: Bool, displayRateLaterButton: Bool) {
        if !withChecks || ratingAlertIsAppropriate() {
            showRatingAlert(displayRateLaterButton)
        }
    }

    private func ratingAlertIsAppropriate() -> Bool {
        return connectedToNetwork()
            && !userHasDeclinedToRate()
            && (ratingAlert?.presentingViewController == nil)
            && !userHasRatedCurrentVersion()
    }

    private func ratingConditionsHaveBeenMet() -> Bool {
        if Self.debug { return true }

        let userDefaults = UserDefaults.standard
        let dateOfFirstLaunch = Date(timeIntervalSince1970: userDefaults.double(forKey: Self.kAppiraterFirstUseDate))
        let timeSinceFirstLaunch = Date().timeIntervalSince(dateOfFirstLaunch)
        let timeUntilRate = 60 * 60 * 24 * Self.daysUntilPrompt
        if timeSinceFirstLaunch < timeUntilRate { return false }

        let useCount = userDefaults.integer(forKey: Self.kAppiraterUseCount)
        if useCount < Self.usesUntilPrompt { return false }

        let sigEventCount = userDefaults.integer(forKey: Self.kAppiraterSignificantEventCount)
        if sigEventCount < Self.significantEventsUntilPrompt { return false }

        let reminderRequestDate = Date(timeIntervalSince1970: userDefaults.double(forKey: Self.kAppiraterReminderRequestDate))
        let timeSinceReminder = Date().timeIntervalSince(reminderRequestDate)
        let timeUntilReminder = 60 * 60 * 24 * Self.timeBeforeReminding
        if timeSinceReminder < timeUntilReminder { return false }

        return true
    }

    private func incrementUseCount() {
        let version = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String ?? ""
        let userDefaults = UserDefaults.standard
        var trackingVersion = userDefaults.string(forKey: Self.kAppiraterCurrentVersion)
        if trackingVersion == nil {
            trackingVersion = version
            userDefaults.set(version, forKey: Self.kAppiraterCurrentVersion)
        }

        if Self.debug {
            print("APPIRATER Tracking version: \(trackingVersion ?? "")")
        }

        if trackingVersion == version {
            var timeInterval = userDefaults.double(forKey: Self.kAppiraterFirstUseDate)
            if timeInterval == 0 {
                timeInterval = Date().timeIntervalSince1970
                userDefaults.set(timeInterval, forKey: Self.kAppiraterFirstUseDate)
            }

            let useCount = userDefaults.integer(forKey: Self.kAppiraterUseCount) + 1
            userDefaults.set(useCount, forKey: Self.kAppiraterUseCount)
            if Self.debug {
                print("APPIRATER Use count: \(useCount)")
            }
        } else {
            userDefaults.set(version, forKey: Self.kAppiraterCurrentVersion)
            userDefaults.set(Date().timeIntervalSince1970, forKey: Self.kAppiraterFirstUseDate)
            userDefaults.set(1, forKey: Self.kAppiraterUseCount)
            userDefaults.set(0, forKey: Self.kAppiraterSignificantEventCount)
            userDefaults.set(false, forKey: Self.kAppiraterRatedCurrentVersion)
            userDefaults.set(false, forKey: Self.kAppiraterDeclinedToRate)
            userDefaults.set(0, forKey: Self.kAppiraterReminderRequestDate)
        }

        userDefaults.synchronize()
    }

    private func incrementSignificantEventCount() {
        let version = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String ?? ""
        let userDefaults = UserDefaults.standard
        var trackingVersion = userDefaults.string(forKey: Self.kAppiraterCurrentVersion)
        if trackingVersion == nil {
            trackingVersion = version
            userDefaults.set(version, forKey: Self.kAppiraterCurrentVersion)
        }

        if Self.debug {
            print("APPIRATER Tracking version: \(trackingVersion ?? "")")
        }

        if trackingVersion == version {
            var timeInterval = userDefaults.double(forKey: Self.kAppiraterFirstUseDate)
            if timeInterval == 0 {
                timeInterval = Date().timeIntervalSince1970
                userDefaults.set(timeInterval, forKey: Self.kAppiraterFirstUseDate)
            }

            let sigEventCount = userDefaults.integer(forKey: Self.kAppiraterSignificantEventCount) + 1
            userDefaults.set(sigEventCount, forKey: Self.kAppiraterSignificantEventCount)
            if Self.debug {
                print("APPIRATER Significant event count: \(sigEventCount)")
            }
        } else {
            userDefaults.set(version, forKey: Self.kAppiraterCurrentVersion)
            userDefaults.set(0, forKey: Self.kAppiraterFirstUseDate)
            userDefaults.set(0, forKey: Self.kAppiraterUseCount)
            userDefaults.set(1, forKey: Self.kAppiraterSignificantEventCount)
            userDefaults.set(false, forKey: Self.kAppiraterRatedCurrentVersion)
            userDefaults.set(false, forKey: Self.kAppiraterDeclinedToRate)
            userDefaults.set(0, forKey: Self.kAppiraterReminderRequestDate)
        }

        userDefaults.synchronize()
    }

    private func incrementAndRate(_ canPromptForRating: Bool) {
        incrementUseCount()
        if canPromptForRating, ratingConditionsHaveBeenMet(), ratingAlertIsAppropriate() {
            showRatingAlert(true)
        }
    }

    private func incrementSignificantEventAndRate(_ canPromptForRating: Bool) {
        incrementSignificantEventCount()
        if canPromptForRating, ratingConditionsHaveBeenMet(), ratingAlertIsAppropriate() {
            showRatingAlert(true)
        }
    }

    private func connectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)

        guard let reachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }

        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(reachability, &flags) {
            return false
        }

        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        let nonWiFi = flags.contains(.transientConnection)
        return (isReachable && !needsConnection) || nonWiFi
    }

    private static func getRootViewController() -> UIViewController? {
        guard var window = UIApplication.shared.keyWindow else { return nil }
        if window.windowLevel != .normal {
            if let normalWindow = UIApplication.shared.windows.first(where: { $0.windowLevel == .normal }) {
                window = normalWindow
            }
        }
        return iterateSubviewsForViewController(window)
    }

    private static func iterateSubviewsForViewController(_ parentView: UIView) -> UIViewController? {
        for subview in parentView.subviews {
            if let responder = subview.next as? UIViewController {
                return topMostViewController(responder)
            }
            if let found = iterateSubviewsForViewController(subview) {
                return found
            }
        }
        return nil
    }

    private static func topMostViewController(_ controller: UIViewController) -> UIViewController {
        var current = controller
        while let presented = current.presentedViewController {
            current = presented
        }
        return current
    }

    // MARK: - StoreKit delegate

    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        Appirater.closeModal()
    }
}
