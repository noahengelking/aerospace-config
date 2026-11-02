import Cocoa
import WebKit
import UniformTypeIdentifiers

final class AppDelegate: NSObject, NSApplicationDelegate, WKScriptMessageHandler, WKNavigationDelegate {
    private var window: NSWindow!
    private var webView: WKWebView!
    private var configURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".aerospace.toml")

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSLog("AeroSpace Config: applicationDidFinishLaunching")
        NSApp.setActivationPolicy(.regular)
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self, name: "aero")
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self

        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1160, height: 820),
                          styleMask: [.titled, .closable, .miniaturizable, .resizable],
                          backing: .buffered, defer: false)
        window.title = "AeroSpace Config"
        window.minSize = NSSize(width: 860, height: 660)
        window.center()
        window.contentView = webView
        window.orderFrontRegardless()
        window.makeKeyAndOrderFront(nil)
        window.makeMain()
        NSApp.activate(ignoringOtherApps: true)

        guard let html = Bundle.main.url(forResource: "index", withExtension: "html") else {
            showError("AeroSpace Config couldn’t load its interface", detail: "The app bundle is missing Contents/Resources/index.html.")
            return
        }
        webView.loadFileURL(html, allowingReadAccessTo: html.deletingLastPathComponent())
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        NSLog("AeroSpace Config: interface loaded")
        if FileManager.default.fileExists(atPath: configURL.path) {
            sendConfigToPage()
        } else {
            chooseConfig()
        }
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        NSLog("AeroSpace Config: interface load failed: %@", error.localizedDescription)
        showError("AeroSpace Config couldn’t load its interface", detail: error.localizedDescription)
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any], let action = body["action"] as? String else { return }
        switch action {
        case "get": sendConfigToPage()
        case "save":
            guard let contents = body["text"] as? String else { return }
            do {
                try contents.write(to: configURL, atomically: true, encoding: .utf8)
                sendConfigToPage()
                reloadAeroSpace()
            } catch {
                showError("Couldn’t save \(configURL.path)", detail: error.localizedDescription)
            }
        case "open": chooseConfig()
        case "openPath":
            guard let path = body["path"] as? String else { return }
            openConfig(at: path)
        default: break
        }
    }

    private func sendConfigToPage() {
        guard let contents = try? String(contentsOf: configURL, encoding: .utf8) else {
            showError("AeroSpace config not found", detail: "Create ~/.aerospace.toml or choose another TOML file using Import.")
            return
        }
        let configJSON = json(contents), pathJSON = json(configURL.path)
        webView.evaluateJavaScript("window.receiveConfig(\(configJSON), \(pathJSON));", completionHandler: nil)
    }

    private func chooseConfig() {
        let panel = NSOpenPanel()
        panel.title = "Open AeroSpace configuration"
        panel.allowedContentTypes = [.plainText]
        panel.allowsOtherFileTypes = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        if panel.runModal() == .OK, let url = panel.url {
            configURL = url
            sendConfigToPage()
        }
    }

    private func openConfig(at path: String) {
        let expandedPath = (path as NSString).expandingTildeInPath
        let url = URL(fileURLWithPath: expandedPath).standardizedFileURL
        guard FileManager.default.fileExists(atPath: url.path) else {
            showError("Config file not found", detail: "Check the path and try again: \(url.path)")
            return
        }
        configURL = url
        sendConfigToPage()
    }

    private func json(_ string: String) -> String {
        let data = try! JSONSerialization.data(withJSONObject: [string], options: [.fragmentsAllowed])
        let array = String(data: data, encoding: .utf8)!
        return String(array.dropFirst().dropLast())
    }

    private func reloadAeroSpace() {
        let candidates = ["/opt/homebrew/bin/aerospace", "/usr/local/bin/aerospace"]
        guard let executable = candidates.first(where: { FileManager.default.isExecutableFile(atPath: $0) }) else { return }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = ["reload-config"]
        do {
            try process.run()
            process.waitUntilExit()
            if process.terminationStatus != 0 {
                showError("Config saved, but AeroSpace couldn’t reload it", detail: "Check the TOML for errors, then reload it from AeroSpace Config.")
            }
        } catch {
            showError("Config saved, but AeroSpace couldn’t reload it", detail: error.localizedDescription)
        }
    }

    private func showError(_ title: String, detail: String) {
        let alert = NSAlert(); alert.messageText = title; alert.informativeText = detail; alert.alertStyle = .warning; alert.addButton(withTitle: "OK")
        alert.beginSheetModal(for: window)
    }
}

let app = NSApplication.shared
let appDelegate = AppDelegate()
app.setActivationPolicy(.regular)
app.delegate = appDelegate
app.run()
