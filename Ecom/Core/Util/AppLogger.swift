//
//  AppLogger.swift
//  Ecom
//
//  Created by Vladimir Rogozhkin on 2026/04/28.
//

import Foundation
import os

nonisolated
public enum AppLogger {
    fileprivate static let subsystem = Bundle.main.bundleIdentifier ?? "com.ecom.app"

    public enum Category: String, CaseIterable, Sendable {
        case network   = "🌐 Network"
        case data      = "💾 Data"
        case domain    = "🧠 Domain"
        case ui        = "📱 UI"
        case streaming = "🎥 Streaming"
        case iot       = "🔌 IoT"
        case auth      = "🔐 Auth"

        fileprivate var logger: Logger {
            Logger(subsystem: AppLogger.subsystem, category: rawValue)
        }
    }
    
    /// Уровень приватности значения в логах.
    /// Не используем `OSLogPrivacy` напрямую: компилятор требует от него compile-time литерал.
    public enum Privacy: Sendable {
        /// Полностью видимо в логах.
        case `public`
        /// Редактируется до `<private>` при отсутствии debug-сессии.
        case `private`
        /// Авто: для встроенных числовых типов = `.public`, для строк/объектов = `.private`.
        case auto
        /// Как `.private`, плюс маркер «не писать в persistent store».
        case sensitive
    }
    
    private static func dispatch(
        type: OSLogType,
        prefix: String,
        message: String,
        privacy: Privacy,
        category: Category
    ) {
        let logger = category.logger
        switch privacy {
        case .public:
            logger.log(level: type, "\(prefix, privacy: .public) \(message, privacy: .public)")
        case .private:
            logger.log(level: type, "\(prefix, privacy: .public) \(message, privacy: .private)")
        case .auto:
            logger.log(level: type, "\(prefix, privacy: .public) \(message, privacy: .auto)")
        case .sensitive:
            logger.log(level: type, "\(prefix, privacy: .public) \(message, privacy: .sensitive)")
        }
    }

    // MARK: - Уровни

    /// Шумная отладочная информация. Компилируется только в Debug-сборках.
    /// `@autoclosure` гарантирует, что выражение не выполняется в Release.
    public static func debug(
        _ message: @autoclosure () -> String,
        category: Category,
        privacy: Privacy = .auto,
        function: StaticString = #function
    ) {
        #if DEBUG
        dispatch(
            type: .debug,
            prefix: "\(function) ➡️",
            message: message(),
            privacy: privacy,
            category: category
        )
        #endif
    }

    /// Информационное сообщение. По умолчанию публично (ID, статусы).
    /// Для токенов/PII явно передавай `privacy: .private`.
    public static func info(
        _ message: String,
        category: Category,
        privacy: Privacy = .public,
        function: StaticString = #function
    ) {
        dispatch(
            type: .info,
            prefix: "\(function) ➡️",
            message: message,
            privacy: privacy,
            category: category
        )
    }

    /// Заметное, но не ошибочное событие — стоит видеть в логах по умолчанию.
        public static func notice(
            _ message: String,
            category: Category,
            privacy: Privacy = .public,
            function: StaticString = #function
        ) {
            dispatch(
                type: .default,
                prefix: "\(function) ➡️",
                message: message,
                privacy: privacy,
                category: category
            )
        }

    /// Что-то пошло не по плану, но приложение продолжает работу.
    public static func warning(
        _ message: String,
        category: Category,
        privacy: Privacy = .public,
        function: StaticString = #function
    ) {
        dispatch(
            type: .error,
            prefix: "⚠️ \(function) ➡️",
            message: message,
            privacy: privacy,
            category: category
        )
    }

    /// Ошибка уровня приложения. Сохраняется в persistent store OSLog.
    public static func error(
        _ error: any Error,
        category: Category,
        privacy: Privacy = .public,
        file: String = #fileID,
        function: StaticString = #function,
        line: Int = #line
    ) {
        dispatch(
            type: .error,
            prefix: "❌ [\(file):\(line)] \(function) ➡️",
            message: error.localizedDescription,
            privacy: privacy,
            category: category
        )
    }

    /// Системный сбой: повреждение состояния, рассинхрон с OS, нарушение инвариантов.
    /// НЕ используй для обычных бизнес-ошибок (сеть упала, валидация не прошла).
    public static func fault(
        _ message: String,
        category: Category,
        privacy: Privacy = .public,
        file: String = #fileID,
        function: StaticString = #function,
        line: Int = #line
    ) {
        dispatch(
            type: .fault,
            prefix: "💥 [\(file):\(line)] \(function) ➡️",
            message: message,
            privacy: privacy,
            category: category
        )
    }
}


//public enum AppLogger {
//    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.ecom.app"
//    
//    public enum Category: String, CaseIterable {
//        case network   = "🌐 Network"
//        case data      = "💾 Data"
//        case domain    = "🧠 Domain"
//        case ui        = "📱 UI"
//        case streaming = "🎥 Streaming"
//        case iot       = "🔌 IoT"
//        case auth      = "🔐 Auth"
//    }
//
//    private static let loggers: [Category: Logger] = Dictionary(
//        uniqueKeysWithValues: Category.allCases.map { category in
//            (category, Logger(subsystem: subsystem, category: category.rawValue))
//        }
//    )
//    
//    // MARK: - Публичные методы
//    
//    /// Публичный лог (виден в релизе). Используется для безопасных данных (ID, статусы).
//        /// - Parameters:
//        ///   - message: Текст сообщения.
//        ///   - category: Слой архитектуры (UI, Domain, Data, Network).
//    public static func info(_ message: String, category: Category, function: String = #function) {
//        let logger = loggers[category] ?? Logger(subsystem: subsystem, category: "General")
//        logger.info("\(function) ➡️ \(message, privacy: .public)")
//    }
//    
//    /// 🔒 Секретный лог. В релизных сборках (App Store) данные скрываются под тегом `<private>`.
//        /// - Parameters:
//        ///   - message: Приватные данные (токены, пароли, номера карт).
//        ///   - category: Слой архитектуры.
//    public static func privateInfo(_ message: String, category: Category, function: String = #function) {
//        let logger = loggers[category] ?? Logger(subsystem: subsystem, category: "General")
//        logger.info("\(function) ➡️ \(message, privacy: .private)")
//    }
//    
//    /// Логирование ошибки (всегда публичное). Автоматически фиксирует файл и строку.
//        /// - Parameters:
//        ///   - error: Объект ошибки.
//        ///   - category: Слой архитектуры, где произошел сбой.
//    public static func error(_ error: Error, category: Category, file: String = #file, function: String = #function, line: Int = #line) {
//        let logger = loggers[category] ?? Logger(subsystem: subsystem, category: "General")
//        let fileName = (file as NSString).lastPathComponent
//        // Ошибки по умолчанию всегда оставляем публичными, так как нам нужно видеть, что упало
//        logger.fault("❌ [\(fileName):\(line)] \(function) ➡️ \(error.localizedDescription, privacy: .public)")
//    }
//}
