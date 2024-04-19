import std/[asyncfutures, asyncdispatch]

proc any*(l: varargs[Future[void]]): Future[void] =
    for f in l:
        if f != nil:
            if result != nil:
                result = result or f
            else:
                result = f

proc checkWithCancel*(fut: Future[void], cancelFut: Future[void]): Future[bool] {.async.} =
    ## Convenience methods for cancellation and timeouts
    ## cancelFut is always checked first and can be nil
    if cancelFut == nil:
        await fut
        return true
    elif cancelFut.finished():
        return false
    else:
        await fut or cancelFut
        if fut.finished():
            return true
        else:
            return false