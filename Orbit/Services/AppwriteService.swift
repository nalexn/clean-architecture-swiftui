import Appwrite
import Foundation

protocol AppwriteServiceProtocol {
    var client: Client { get }
    var account: Account { get }
    var databases: Databases { get }
    // Add other Appwrite services as needed
}

class AppwriteService: AppwriteServiceProtocol {
    let client: Client
    let account: Account
    let databases: Databases
    // Add other Appwrite services as needed

    init() {

        client = Client()
            .setEndpoint("https://cloud.appwrite.io/v1")
            .setProject("67017126001e334dd053")
            .setSelfSigned(true)  // For self signed certificates, only use for development

        account = Account(client: client)
        databases = Databases(client: client)

    }
}
