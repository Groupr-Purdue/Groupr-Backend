import PackageDescription

let package = Package(
    name: "backend",
    targets: [
        Target(name: "App", dependencies: ["Library"]),
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 3),
        .Package(url:"https://github.com/vapor/jwt.git", majorVersion: 0, minor: 6),
        .Package(url:"https://github.com/vapor/sqlite-provider.git", majorVersion: 1, minor: 1)
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources",
    ]
)
