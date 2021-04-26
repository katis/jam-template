const path = require("path");
const chokidar = require("chokidar");
const rx = require("rxjs");
const op = require("rxjs/operators");
const childProcess = require("child_process");
const express = require("express");

const HAXE_SERVER_PORT = 6000;

const compile = () =>
  new Promise((resolve) => {
    childProcess.exec(`haxe --connect ${HAXE_SERVER_PORT} compile.hxml`, () =>
      resolve()
    );
  });

const watchSrc = chokidar.watch(path.join(__dirname, "src"), {
  depth: 20,
});

const watchPublic = chokidar.watch(path.join(__dirname, "public"), {
  depth: 2,
});

const srcChanges = rx.fromEvent(watchSrc, "all").pipe(op.debounceTime(200));
const publicChanges = rx
  .fromEvent(watchPublic, "all")
  .pipe(op.debounceTime(50));

srcChanges.pipe(op.concatMap(() => rx.from(compile()))).subscribe(() => {});

const app = express();

app.use(express.static("public"));

app.get("/reload-events", (_req, res) => {
  res.writeHead(200, {
    "Content-Type": "text/event-stream",
    "Cache-Control": "no-cache",
    Connection: "keep-alive",
  });

  const intervalSub = rx.interval(1000).subscribe(() => {
    res.write(": ping\n\n");
  });

  const reloadSub = publicChanges.subscribe(() => {
    res.write("event: reload\ndata: 0\n\n");
  });

  res.once("close", () => {
    intervalSub.unsubscribe();
    reloadSub.unsubscribe();
  });
});

const PORT = 3000;
app.listen(PORT, () => console.log(`Listening at http://localhost:${PORT}`));
