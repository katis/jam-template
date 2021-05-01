const path = require("path");
const chokidar = require("chokidar");
const rx = require("rxjs");
const op = require("rxjs/operators");
const childProcess = require("child_process");
const express = require("express");

const HAXE_SERVER_PORT = 6000;
const SRC = path.join(__dirname, "src");

const compile = () =>
  new rx.Observable((sub) => {
    childProcess.exec(
      `haxe --connect ${HAXE_SERVER_PORT} compile.hxml`,
      (error) => {
        if (error) {
          sub.error(error);
        } else {
          sub.next("OK");
          sub.complete();
        }
      }
    );
  });

const reloads = new rx.Subject();

const watchSrc = chokidar.watch(SRC, { depth: 20 });
const compilations = rx
  .fromEvent(watchSrc, "all")
  .pipe(op.debounceTime(100))
  .pipe(op.startWith("START"))
  .pipe(op.tap(() => "COMPILED!"))
  .pipe(op.exhaustMap(() => compile().pipe(op.catchError(() => rx.EMPTY))));
compilations.subscribe(reloads);

const app = express();

app.use(express.static("public"));

app.get("/reload-events", (_req, res) => {
  res.writeHead(200, {
    "Content-Type": "text/event-stream",
    "Cache-Control": "no-cache",
    Connection: "keep-alive",
  });

  const pingSub = rx.interval(1000).subscribe(() => {
    res.write(": ping\n\n");
  });

  const reloadSub = reloads.subscribe(() => {
    res.write("event: reload\ndata: 0\n\n");
  });

  res.once("close", () => {
    pingSub.unsubscribe();
    reloadSub.unsubscribe();
  });
});

const PORT = 3000;
app.listen(PORT, () => console.log(`Listening at http://localhost:${PORT}`));
