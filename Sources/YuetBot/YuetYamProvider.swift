import Foundation
import SQLite3

struct YuetYamProvider {
        private static let database: OpaquePointer? = {
                let path: String = "/srv/yuetbot/yuetyam.sqlite3"
                var db: OpaquePointer?
                if sqlite3_open_v2(path, &db, SQLITE_OPEN_READONLY, nil) == SQLITE_OK {
                        return db
                } else {
                        return nil
                }
        }()
        
        static func match(for text: String) -> [String] {
                let token: Int64 = Int64(text.hash)
                var yuetyams: [String] = []
                let queryString = "SELECT * FROM yuetyamtable WHERE token = \(token);"
                var queryStatement: OpaquePointer? = nil
                if sqlite3_prepare_v2(database, queryString, -1, &queryStatement, nil) == SQLITE_OK {
                        while sqlite3_step(queryStatement) == SQLITE_ROW {
                                // token = sqlite3_column_int64(queryStatement, 0)
                                let yuetyam: String = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                                yuetyams.append(yuetyam)
                        }
                }
                sqlite3_finalize(queryStatement)
                return yuetyams.deduplicated()
        }
}

private extension Array where Element: Hashable {
        func deduplicated() -> [Element] {
                var set: Set<Element> = Set<Element>()
                return filter { set.insert($0).inserted }
        }
}
