
import Foundation

extension Data {
    func decode<T: Decodable>(model: T.Type) -> T? {
        do {
            return try JSONDecoder().decode(model, from: self)
        } catch {
//            print(error)
            return nil
        }
    }
}
