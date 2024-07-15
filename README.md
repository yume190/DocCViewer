# DocC Viewer (POC)

---

## Mac

### Requied Commands

* swift(5.10, Xcode 15.4)
* tar
* curl
* zip
* git

---

## iOS

---

### Dir

```sh
# dist/$repo/tags/$tag/
├── dist
│   ├── apple_swift_argument_parser
│   ├── apple_swift_async_algorithms
│   └── pointfreeco_swift_composable_architecture
└── git
    ├── apple_swift_argument_parser
    ├── apple_swift_async_algorithms
    └── pointfreeco_swift_composable_architecture
```

---

### TODOS(ISSUE)

 - [ ] UI Loading/Process
 - [ ] iOS Preview Server not close when app closed
 - [ ] iOS untar tca.tar.gz need 1GB memory
   * tca.tar.gz  50 MB
   * tca        400 MB

### TODOS

- [ ] Find Other HTTP Server
  - [ ] change base url
- [ ] Support Latest(main/master head commit)
- [ ] build static site by single `md`?
- [ ] build static site when repo doesn't contain `.docc`?
- [ ] remove `swift-docc`(Mac)
- [ ] filter (tag/commits/branch)
