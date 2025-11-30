import Foundation

// MARK: - Output Formatting System

/// Comprehensive output formatting system with TTY detection and automatic format switching
struct OutputFormatter {
    
    // MARK: - Output Format Options
    
    enum Format {
        case json           // Machine-readable JSON
        case summary        // Human-readable summary
        case detailed       // Detailed human-readable
        case compact        // Compact human-readable
        case minimal        // Minimal output (85%+ size reduction)
        case auto           // Auto-detect based on context
    }
    
    // MARK: - Terminal Detection
    
    let isTTY: Bool
    let isColored: Bool
    private let forceFormat: Format?
    
    // MARK: - Initialization
    
    init(force format: Format? = nil, forceColored: Bool? = nil) {
        self.forceFormat = format
        self.isTTY = isatty(STDOUT_FILENO) != 0
        
        // Check color preferences
        let noColor = ProcessInfo.processInfo.environment["NO_COLOR"] != nil
        let forceColor = (forceColored != nil) ? forceColored! : (ProcessInfo.processInfo.environment["FORCE_COLOR"] != nil)
        
        self.isColored = isTTY && !noColor || forceColor
    }
    
    // MARK: - Public Interface
    
    func format<T: Codable>(_ value: T, as format: Format = .auto) -> String {
        let resolvedFormat = resolveFormat(format)
        
        switch resolvedFormat {
        case .json:
            return formatAsJSON(value)
        case .summary:
            return formatAsSummary(value)
        case .detailed:
            return formatAsDetailed(value)
        case .compact:
            return formatAsCompact(value)
        case .minimal:
            return formatAsMinimal(value)
        case .auto:
            return isTTY ? formatAsSummary(value) : formatAsJSON(value)
        }
    }
    
    func formatText(_ text: String, as format: Format = .auto) -> String {
        let resolvedFormat = resolveFormat(format)
        
        switch resolvedFormat {
        case .json:
            return formatTextAsJSON(text)
        case .summary:
            return formatTextAsSummary(text)
        case .detailed:
            return formatTextAsDetailed(text)
        case .compact:
            return formatTextAsCompact(text)
        case .minimal:
            return formatTextAsMinimal(text)
        case .auto:
            return isTTY ? formatTextAsSummary(text) : formatTextAsJSON(text)
        }
    }
    
    // MARK: - Progress Display
    
    func showProgress(
        title: String,
        current: Int,
        total: Int,
        phase: String = "",
        currentItem: String = "",
        format: Format = .auto
    ) {
        guard isTTY else { return } // Skip progress in non-TTY environments
        
        let resolvedFormat = resolveFormat(format)
        guard resolvedFormat == .auto || resolvedFormat == .summary else { return }
        
        let percentage = total > 0 ? Double(current) / Double(total) * 100 : 0
        let progressBar = createProgressBar(percentage)
        
        clearLine()
        
        let phaseText = phase.isEmpty ? "" : " [\(phase)]"
        let itemText = currentItem.isEmpty ? "" : " - \(currentItem)"
        
        print("\(progressBar) \(current)/\(total) (\(String(format: "%.1f", percentage))%)\(phaseText)\(itemText)", terminator: "")
        fflush(stdout)
    }
    
    func showSpinner(title: String, format: Format = .auto) {
        guard isTTY else { return }
        
        let resolvedFormat = resolveFormat(format)
        guard resolvedFormat == .auto || resolvedFormat == .summary else { return }
        
        let frames = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
        var frameIndex = 0
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            guard self.isTTY else {
                timer.invalidate()
                return
            }
            
            clearLine()
            print("\(frames[frameIndex]) \(title)", terminator: "")
            fflush(stdout)
            
            frameIndex = (frameIndex + 1) % frames.count
        }
    }
    
    func hideProgress() {
        guard isTTY else { return }
        clearLine()
    }
    
    // MARK: - Format Resolution
    
    private func resolveFormat(_ format: Format) -> Format {
        if let forced = forceFormat { return forced }
        
        // Auto-detection based on context
        switch format {
        case .auto:
            return isTTY ? .summary : .json
        default:
            return format
        }
    }
    
    // MARK: - JSON Formatting
    
    private func formatAsJSON<T: Codable>(_ value: T) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        do {
            let data = try encoder.encode(value)
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            return #"{"error": "Failed to encode JSON", "details": "\#(error.localizedDescription)"}"#
        }
    }
    
    private func formatTextAsJSON(_ text: String) -> String {
        let result: [String: Any] = ["text": text]
        
        if let data = try? JSONSerialization.data(withJSONObject: result),
           let jsonString = String(data: data, encoding: .utf8) {
            return jsonString
        }
        
        return #"{"text": "Failed to encode"}"#
    }
    
    // MARK: - Summary Formatting
    
    private func formatAsSummary<T: Codable>(_ value: T) -> String {
        let mirror = Mirror(reflecting: value)
        
        guard !mirror.children.isEmpty else {
            return String(describing: value)
        }
        
        var output = [String]()
        
        for child in mirror.children {
            let key = child.label ?? "unknown"
            let value = child.value
            
            if let codableValue = value as? any Codable {
                output.append(formatKeyValue(key: key, value: codableValue, style: .summary))
            } else {
                output.append(formatKeyValue(key: key, value: value, style: .summary))
            }
        }
        
        return output.joined(separator: "\n")
    }
    
    private func formatTextAsSummary(_ text: String) -> String {
        return text
    }
    
    // MARK: - Detailed Formatting
    
    private func formatAsDetailed<T: Codable>(_ value: T) -> String {
        let mirror = Mirror(reflecting: value)
        
        guard !mirror.children.isEmpty else {
            return String(describing: value)
        }
        
        var output = [String]()
        output.append("=== \(type(of: value)) ===")
        
        for child in mirror.children {
            let key = child.label ?? "unknown"
            let value = child.value
            
            if let codableValue = value as? any Codable {
                output.append(formatKeyValue(key: key, value: codableValue, style: .detailed))
            } else {
                output.append(formatKeyValue(key: key, value: value, style: .detailed))
            }
        }
        
        return output.joined(separator: "\n")
    }
    
    private func formatTextAsDetailed(_ text: String) -> String {
        return "=== Text ===\n\(text)"
    }
    
    // MARK: - Compact Formatting
    
    private func formatAsCompact<T: Codable>(_ value: T) -> String {
        let mirror = Mirror(reflecting: value)
        
        guard !mirror.children.isEmpty else {
            return String(describing: value)
        }
        
        var output = [String]()
        
        for child in mirror.children {
            let key = child.label ?? "unknown"
            let value = child.value
            
            if let codableValue = value as? any Codable {
                output.append(formatKeyValue(key: key, value: codableValue, style: .compact))
            } else {
                output.append(formatKeyValue(key: key, value: value, style: .compact))
            }
        }
        
        return output.joined(separator: " | ")
    }
    
    private func formatTextAsCompact(_ text: String) -> String {
        return text.replacingOccurrences(of: "\n", with: " ").replacingOccurrences(of: "  ", with: " ")
    }
    
    // MARK: - Minimal Formatting
    
    private func formatAsMinimal<T: Codable>(_ value: T) -> String {
        // Extract only the most essential information
        let mirror = Mirror(reflecting: value)
        
        guard !mirror.children.isEmpty else {
            return String(describing: value)
        }
        
        var essentialInfo = [String]()
        
        for child in mirror.children {
            let key = child.label ?? "unknown"
            
            // Only include essential keys
            if ["status", "success", "count", "total", "errors", "warnings"].contains(key.lowercased()) {
                essentialInfo.append("\(key): \(child.value)")
            }
        }
        
        return essentialInfo.joined(separator: " | ")
    }
    
    private func formatTextAsMinimal(_ text: String) -> String {
        // Remove all formatting and extra whitespace
        return text
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
            .replacingOccurrences(of: "  ", with: " ")
    }
    
    // MARK: - Helper Methods
    
    private enum ValueStyle {
        case summary, detailed, compact
    }
    
    private func formatKeyValue(key: String, value: Any, style: ValueStyle) -> String {
        let formattedValue: String
        
        switch style {
        case .summary:
            formattedValue = formatValueForSummary(value)
        case .detailed:
            formattedValue = formatValueForDetailed(value)
        case .compact:
            formattedValue = formatValueForCompact(value)
        }
        
        switch style {
        case .summary:
            return isColored ? "🎯 \(key): \(formattedValue)" : "\(key): \(formattedValue)"
        case .detailed:
            return isColored ? "📋 \(key):\n    \(formattedValue.replacingOccurrences(of: "\n", with: "\n    "))" : "\(key):\n    \(formattedValue.replacingOccurrences(of: "\n", with: "\n    "))"
        case .compact:
            return "\(key)=\(formattedValue)"
        }
    }
    
    private func formatValueForSummary(_ value: Any) -> String {
        if let stringValue = value as? String {
            return stringValue.count > 50 ? String(stringValue.prefix(50)) + "..." : stringValue
        }
        
        if let arrayValue = value as? [Any] {
            return "[\(arrayValue.count) items]"
        }
        
        if let dictValue = value as? [String: Any] {
            return "[\(dictValue.count) entries]"
        }
        
        return String(describing: value)
    }
    
    private func formatValueForDetailed(_ value: Any) -> String {
        return String(describing: value)
    }
    
    private func formatValueForCompact(_ value: Any) -> String {
        if let stringValue = value as? String {
            return stringValue.replacingOccurrences(of: " ", with: "_")
        }
        
        if let arrayValue = value as? [Any] {
            return "[\(arrayValue.count)]"
        }
        
        if let dictValue = value as? [String: Any] {
            return "{\(dictValue.count)}"
        }
        
        return String(describing: value).prefix(20) + (String(describing: value).count > 20 ? "..." : "")
    }
    
    private func createProgressBar(_ percentage: Double) -> String {
        let width = 20
        let filled = Int(Double(width) * percentage / 100)
        let empty = width - filled
        
        let filledChars = String(repeating: "█", count: filled)
        let emptyChars = String(repeating: "░", count: empty)
        
        return isColored ? "[\(filledChars)\(emptyChars)]" : "[\(filled)/\(width)]"
    }
    
    private func clearLine() {
        print("\r", terminator: "")
        let columns = Int(columns())
        if columns > 0 {
            print(String(repeating: " ", count: columns), terminator: "")
        }
        print("\r", terminator: "")
    }
    
    // MARK: - ANSI Color Support
    
    enum Color {
        static let red = "\u{001B}[31m"
        static let green = "\u{001B}[32m"
        static let yellow = "\u{001B}[33m"
        static let blue = "\u{001B}[34m"
        static let magenta = "\u{001B}[35m"
        static let cyan = "\u{001B}[36m"
        static let reset = "\u{001B}[0m"
        static let bold = "\u{001B}[1m"
    }
    
    // MARK: - Terminal Information
    
    private func columns() -> Int {
        // Default to 80 columns if we can't determine terminal size
        return 80
    }
}

// MARK: - Progress Indicator

struct ProgressIndicator {
    private let formatter: OutputFormatter
    private var startTime: Date
    
    init(formatter: OutputFormatter) {
        self.formatter = formatter
        self.startTime = Date()
    }
    
    mutating func start(title: String, format: OutputFormatter.Format = .auto) {
        formatter.showSpinner(title: title, format: format)
        startTime = Date()
    }
    
    mutating func update(
        current: Int,
        total: Int,
        phase: String = "",
        currentItem: String = "",
        format: OutputFormatter.Format = .auto
    ) {
        formatter.hideProgress()
        formatter.showProgress(
            title: "",
            current: current,
            total: total,
            phase: phase,
            currentItem: currentItem,
            format: format
        )
    }
    
    mutating func finish(message: String, success: Bool = true) {
        formatter.hideProgress()
        
        let duration = Date().timeIntervalSince(startTime)
        let durationText = String(format: "%.1f", duration)
        
        if success {
            print(formatter.isColored ? "\(OutputFormatter.Color.green)✅\(OutputFormatter.Color.reset) \(message) (\(durationText)s)" : "✅ \(message) (\(durationText)s)")
        } else {
            print(formatter.isColored ? "\(OutputFormatter.Color.red)❌\(OutputFormatter.Color.reset) \(message) (\(durationText)s)" : "❌ \(message) (\(durationText)s)")
        }
    }
}

// MARK: - JSON Output Extensions

extension Encodable where Self: Decodable {
    func formattedOutput(
        format: OutputFormatter.Format = .auto,
        colored: Bool = false
    ) -> String {
        let formatter = OutputFormatter(force: format, forceColored: colored)
        return formatter.format(self, as: format)
    }
}

// MARK: - CLI Output Helpers

struct CLIOutput {
    private let formatter: OutputFormatter
    
    init(format: OutputFormatter.Format = .auto, colored: Bool? = nil) {
        self.formatter = OutputFormatter(force: format, forceColored: colored)
    }
    
    func success(_ message: String) {
        if formatter.isColored {
            print("\(OutputFormatter.Color.green)✅\(OutputFormatter.Color.reset) \(message)")
        } else {
            print("✅ \(message)")
        }
    }
    
    func error(_ message: String) {
        if formatter.isColored {
            print("\(OutputFormatter.Color.red)❌\(OutputFormatter.Color.reset) \(message)")
        } else {
            print("❌ \(message)")
        }
    }
    
    func warning(_ message: String) {
        if formatter.isColored {
            print("\(OutputFormatter.Color.yellow)⚠️\(OutputFormatter.Color.reset) \(message)")
        } else {
            print("⚠️  \(message)")
        }
    }
    
    func info(_ message: String) {
        if formatter.isColored {
            print("\(OutputFormatter.Color.blue)ℹ️\(OutputFormatter.Color.reset) \(message)")
        } else {
            print("ℹ️  \(message)")
        }
    }
    
    func section(_ title: String) {
        let separator = String(repeating: "=", count: title.count + 4)
        if formatter.isColored {
            print("\(OutputFormatter.Color.bold)\(separator)\(OutputFormatter.Color.reset)")
            print("\(OutputFormatter.Color.bold)\(OutputFormatter.Color.reset) \(title) ")
            print("\(OutputFormatter.Color.bold)\(separator)\(OutputFormatter.Color.reset)")
        } else {
            print(separator)
            print("  \(title)  ")
            print(separator)
        }
    }
}