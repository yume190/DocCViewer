// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SPM",
    platforms: [
//      .macOS(.v10_15),
//      .iOS(.v13)
      .macOS(.v13),
      .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "SPM", targets: ["SPM"]),
        .executable(name: "buildDocc", targets: ["BuildDocc"])
    ],
    dependencies: [
        /// swift-5.10-RELEASE  49f5c5736344a1bb562773170176eb224dbc3c33
        /// swift-5.9.2-RELEASE 2b7ebe65a258faf26e7bf57c3b7a36d727017518
        /// swift-argument-parser 1.2.2
//        .package(
//            url: "https://github.com/apple/swift-package-manager",
//            revision: "49f5c5736344a1bb562773170176eb224dbc3c33"),
      .package(
          url: "https://github.com/apple/swift-package-manager",
          branch: "release/6.0"),
    // .package(
    //     url: "https://github.com/apple/swift-package-manager",
    //     revision: "swift-5.10.1-RELEASE"),
    
      .package(
          url: "https://github.com/apple/swift-argument-parser",
          from: "1.2.3"),
          //swift-5.10-RELEASE
    // swift-5.10.1-RELEASE
      .package(name: "swift-docc", path: "../swift-docc"),
      
      .package(url: "https://github.com/kylef/PathKit", from: "1.0.1"),
      .package(url: "https://github.com/mbernson/SwiftGit2", branch: "swift-package-manager"),
      .package(url: "https://github.com/Zollerboy1/SwiftCommand.git", from: "1.4.0"),
      .package(url: "https://github.com/tsolomko/SWCompression.git", from: "4.8.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.

        .target(
            name: "SPM",
            dependencies: [  
              "PathKit",
              "SwiftGit2",
              "SWCompression",

              
              .product(name: "SwiftDocC", package: "swift-docc"),
              .product(name: "SwiftDocCUtilities", package: "swift-docc"),
              /// MAC Only
              .product(name: "SwiftPMDataModel-auto", package: "swift-package-manager", condition: .when(platforms: [.macOS])),
              .product(name: "SwiftCommand", package: "SwiftCommand", condition: .when(platforms: [.macOS])),
              
            ],
            resources: [
              .copy("dist")
            ]
        ),
        .executableTarget(
          name: "BuildDocc",
          dependencies: [
              .product(name: "ArgumentParser", package: "swift-argument-parser"),
              "SPM"
          ]
        ),
        .testTarget(
            name: "SPMTests",
            dependencies: ["SPM"],
            exclude: [
              "index.json",
              "index2.json",
            ]
//            resources: [
//              .copy("index.json")
//            ]
        ),
    ]
)
