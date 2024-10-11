import SafariServices
import StoreKit
import UIKit
import WebKit

final class AppActions: NSObject {
    static let shared = AppActions()
    private var webView: WKWebView?
    
    // MARK: - Private Initializer
    override private init() {}
    
    // MARK: - Public Methods
    func shareApp() {
        guard let currentViewController = getCurrentViewController() else { return }
        shareAppInternal(from: currentViewController)
    }
    
    func rateApp() {
        guard let currentViewController = getCurrentViewController() else { return }
        rateAppInternal(from: currentViewController)
    }
    
    func showUsagePolicy() {
        guard let currentViewController = getCurrentViewController() else { return }
        openWebPage(url: AppLinks.usagePolicyURL, from: currentViewController)
    }
    
    func openWebPage() {
        guard let currentViewController = getCurrentViewController() else { return }
        openMainWebPage(url: CategoryDataManager.idea, from: currentViewController)
    }
    
    // MARK: - Private Methods
    private func shareAppInternal(from viewController: UIViewController, sourceView: UIView? = nil, barButtonItem: UIBarButtonItem? = nil) {
        let itemsToShare = [AppLinks.appShareURL]
        let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        
        // For iPad
        if let popoverController = activityViewController.popoverPresentationController {
            if let barButtonItem = barButtonItem {
                popoverController.barButtonItem = barButtonItem
            } else if let sourceView = sourceView {
                popoverController.sourceView = sourceView
                popoverController.sourceRect = sourceView.bounds
            } else {
                popoverController.sourceView = viewController.view
                popoverController.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
        }
        
        activityViewController.excludedActivityTypes = [.addToReadingList, .assignToContact]
        viewController.present(activityViewController, animated: true, completion: nil)
    }
    
    private func rateAppInternal(from viewController: UIViewController) {
        if #available(iOS 14.0, *) {
            if let scene = viewController.view.window?.windowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        } else {
            if UIApplication.shared.canOpenURL(AppLinks.appStoreReviewURL) {
                UIApplication.shared.open(AppLinks.appStoreReviewURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    private func openWebPage(url: URL, from viewController: UIViewController) {
        let webView = WKWebView()
        webView.navigationDelegate = viewController as? WKNavigationDelegate
        webView.load(URLRequest(url: url))
        
        let webViewViewController = UIViewController()
        webViewViewController.view = webView
        
        viewController.present(webViewViewController, animated: true, completion: nil)
    }
    
    private func getCurrentViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            return nil
        }
        
        var viewController = rootViewController
        while let presentedViewController = viewController.presentedViewController {
            viewController = presentedViewController
        }
        
        return viewController
    }
    
    private func openMainWebPage(url: URL, from viewController: UIViewController) {
        let config = WKWebViewConfiguration()
        let websiteDataStore = WKWebsiteDataStore.default()
        config.websiteDataStore = websiteDataStore

        let newWebView = WKWebView(frame: .zero, configuration: config)
        newWebView.navigationDelegate = self
        webView = newWebView

        if let savedData = UserDefaults.standard.data(forKey: "SavedCookiesKey"),
           let cookies = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, HTTPCookie.self], from: savedData) as? [HTTPCookie] {
            cookies.forEach { cookie in
                newWebView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie) {
                    print("Got cookie: \(cookie.name) = \(cookie.value)")
                }
            }
        }

        newWebView.load(URLRequest(url: url))

        let webViewController = UIViewController()
        webViewController.view.addSubview(newWebView)
        newWebView.translatesAutoresizingMaskIntoConstraints = false

        newWebView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let navController = UINavigationController(rootViewController: webViewController)
        navController.modalPresentationStyle = .fullScreen
        navController.navigationBar.isHidden = true

        viewController.present(navController, animated: true, completion: nil)
    }
}

extension AppActions: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            let data = try? NSKeyedArchiver.archivedData(withRootObject: cookies, requiringSecureCoding: false)
            UserDefaults.standard.set(data, forKey: "SavedCookiesKey")

            print("Saved next cookies:")
            cookies.forEach { cookie in
                print("\(cookie.name): \(cookie.value)")
            }
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let savedData = UserDefaults.standard.data(forKey: "SavedCookiesKey"),
           let cookies = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, HTTPCookie.self], from: savedData) as? [HTTPCookie] {
            let dispatchGroup = DispatchGroup()

            cookies.forEach { cookie in
                dispatchGroup.enter()
                webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie) {
                    print("Got next cookie: \(cookie.name) = \(cookie.value)")
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
    }
}
