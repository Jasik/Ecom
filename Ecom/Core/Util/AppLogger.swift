//
//  AppLogger.swift
//  Ecom
//
//  Created by Vladimir Rogozhkin on 2026/04/28.
//

import Foundation
import os

public enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.ecom.app"
    
    public enum Category: String {
        case network = "🌐 Network"
        case data    = "💾 Data"
        case domain  = "🧠 Domain"
        case ui      = "📱 UI"
        case streaming = "🎥 Streaming"
        case iot     = "🔌 IoT"
        case auth    = "🔐 Auth"
    }
    
    private static let loggers: [Category: Logger] = [
        .network: Logger(subsystem: subsystem, category: Category.network.rawValue),
        .data: Logger(subsystem: subsystem, category: Category.data.rawValue),
        .domain: Logger(subsystem: subsystem, category: Category.domain.rawValue),
        .ui: Logger(subsystem: subsystem, category: Category.ui.rawValue),
        .streaming: Logger(subsystem: subsystem, category: Category.streaming.rawValue),
        .iot: Logger(subsystem: subsystem, category: Category.iot.rawValue),
        .auth: Logger(subsystem: subsystem, category: Category.auth.rawValue)
    ]
    
    // MARK: - Публичные методы
    
    /// Публичный лог (виден в релизе). Используется для безопасных данных (ID, статусы).
        /// - Parameters:
        ///   - message: Текст сообщения.
        ///   - category: Слой архитектуры (UI, Domain, Data, Network).
    public static func info(_ message: String, category: Category, function: String = #function) {
        let logger = loggers[category] ?? Logger(subsystem: subsystem, category: "General")
        logger.info("\(function) ➡️ \(message, privacy: .public)")
    }
    
    /// 🔒 Секретный лог. В релизных сборках (App Store) данные скрываются под тегом `<private>`.
        /// - Parameters:
        ///   - message: Приватные данные (токены, пароли, номера карт).
        ///   - category: Слой архитектуры.
    public static func privateInfo(_ message: String, category: Category, function: String = #function) {
        let logger = loggers[category] ?? Logger(subsystem: subsystem, category: "General")
        logger.info("\(function) ➡️ \(message, privacy: .private)")
    }
    
    /// Логирование ошибки (всегда публичное). Автоматически фиксирует файл и строку.
        /// - Parameters:
        ///   - error: Объект ошибки.
        ///   - category: Слой архитектуры, где произошел сбой.
    public static func error(_ error: Error, category: Category, file: String = #file, function: String = #function, line: Int = #line) {
        let logger = loggers[category] ?? Logger(subsystem: subsystem, category: "General")
        let fileName = (file as NSString).lastPathComponent
        // Ошибки по умолчанию всегда оставляем публичными, так как нам нужно видеть, что упало
        logger.fault("❌ [\(fileName):\(line)] \(function) ➡️ \(error.localizedDescription, privacy: .public)")
    }
}
