import FirebaseDatabase
class FirebaseService {
    private let database = Database.database().reference()
    
    // Function to save data
    func saveChildActivity(childID: String, activityData: [String: Any], completion: @escaping (Error?) -> Void) {
        database.child("children/\(childID)/activities").setValue(activityData) { error, _ in
            completion(error)
        }
    }
    
    // Function to fetch data
    func fetchChildActivity(childID: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
        database.child("children/\(childID)/activities").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion(nil, nil)
                return
            }
            completion(value, nil)
        }
    }
}
