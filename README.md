## Dev

Use VSCode

Open a `.hx` or `.hxml` file in the project, so that the Haxe language server
starts in VSCode.

```
haxelib newrepo
haxelib install compile.hxml
npm i
npm start
```

Open http://localhost:3000

### Possible problems

The `dev-server.js` script detects file changes in `src/` and asks the Haxe
language server running at port 6000 to compile it.
VSCode starts a languages server when a Haxe file is opened.
Check "Output -> Haxe" tab to see if the server is running.
