import Appwrite
import Foundation
import JSONCodable

let processInfo = ProcessInfo.processInfo

let PROJECT_ID = "67017126001e334dd053"
let APPWRITE_API_KEY =
  processInfo.environment["APPWRITE_API_KEY"]
  ?? ""
let DATABASE_ID = "orbit"
let COLLECTION_ID = "users"

func deleteUnmatchedUsers() async {
  let client = Client()
    .setEndpoint("https://cloud.appwrite.io/v1")
    .setProject(PROJECT_ID)
    .setKey(APPWRITE_API_KEY)
  let users = Users(client)
  do {
    // Fetch all Appwrite users
    let userList = try await users.list()

    // Fetch all accountIds from your users collection
    let accountIds = try await fetchAccountIds(client: client)

    for user in userList.users {
      if !accountIds.contains(user.id) {
        do {
          try await users.delete(userId: user.id)
          print("Deleted user: \(user.id)")
        } catch {
          print("Error deleting user \(user.id): \(error.localizedDescription)")
        }
      } else {
        print("Skipping user \(user.id) as it matches an accountId")
      }
    }

    print("Deletion process completed")
  } catch {
    print("Error: \(error.localizedDescription)")
  }
}

func fetchAccountIds(client: Client) async throws -> Set<String> {
  let databases = Databases(client)
  var accountIds = Set<String>()

  let documents = try await databases.listDocuments(
    databaseId: DATABASE_ID,
    collectionId: COLLECTION_ID,
    queries: [Query.select(["accountId"])]
    // limit: 100,
    // cursor: cursor
  )
  print("Fetched \(documents.documents.count) documents")
  for doc in documents.documents {
    if let data = doc.data as! [String: AnyCodable]?, let accountId = data["accountId"] as? String,
      !accountId.isEmpty
    {
      accountIds.insert(accountId)
    }
  }

  // cursor = documents.cursor
  // } while cursor != nil

  return accountIds
}

Task {
  await deleteUnmatchedUsers()
}

// Keep the main thread alive
RunLoop.main.run()
