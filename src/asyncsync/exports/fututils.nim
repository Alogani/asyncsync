import std/[asyncdispatch, asyncfutures]

proc any*(l: varargs[Future[void]]): Future[void] =
    for f in l:
        if f != nil:
            if result != nil:
                result = result or f
            else:
                result = f

proc wait*(fut: Future[void], cancelFut: Future[void]): Future[bool] {.async.} =
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

proc then*[T2](fut: Future[void], cb: proc(): Future[T2]): Future[T2] {.async.} =
    ## Add callback in a synchronous way (awaitable)
    await fut
    await cb()

proc then*[T1, T2](fut: Future[T1], cb: proc(data: T1): Future[T2]): Future[T2] {.async.} =
    ## Add callback in a synchronous way (awaitable)
    await cb(await fut)

proc then*[T1, T2](fut: Future[T1], cb: proc(): Future[T2]): Future[T2] {.async.} =
    ## Add callback in a synchronous way (awaitable)
    discard await fut
    await cb()
