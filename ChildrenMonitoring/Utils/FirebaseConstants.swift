let firebaseService = FirebaseService()
// Save data example
firebaseService.saveChildActivity(childID: "child123", activityData: ["location": "home", "time": "10:00 AM"]) { error in
    if let error = error {
        print("Error saving data: \(error.localizedDescription)")
    } else {
        print("Data saved successfully.")
    }
}
// Fetch data example
firebaseService.fetchChildActivity(childID: "child123") { data, error in
    if let data = data {
        print("Child activity: \(data)")
    } else if let error = error {
        print("Error fetching data: \(error.localizedDescription)")
    }
}
