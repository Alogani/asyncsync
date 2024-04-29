import asyncsync

import std/unittest


proc main() {.async.} =
    test "Then":
        var futNum = newFuture[int]()
        futNum.complete(42)

        check (await futNum.then(proc(i: int): Future[int] {.async.} =
            i + 10
        )) == 52

        check (await sleepAsync(0).then(proc(): Future[int] {.async.} =
            42
        )) == 42


waitFor main()