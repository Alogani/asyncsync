import std/[asyncdispatch]
import std/importutils


privateAccess(FutureBase)


type
    Event* = distinct Future[void]
        ## Waiters wakening can be unordered (According to asyncdispatch doc: in the order of await macro call)
        ## For ordered events, cleaner method is to use in combination with a lock


proc clean*[T](fut: Future[T])


proc new*(T: type Event): T
proc wait*(self: Event): Future[void]
proc trigger*(self: Event)
proc isTriggered*(self: Event): bool
proc clear*(self: Event)
proc addCallback*(self: Event; cb: proc () {.closure, gcsafe.}) {.borrow.}
proc clearCallbacks*(self: Event) {.borrow.}
converter toBool*(self: Event): bool


proc clean*[T](fut: Future[T]) =
    fut.finished = false
    fut.error = nil


proc new*(T: type Event): T =
    T(newFuture[void]("Event"))

proc wait*(self: Event): Future[void] =
    Future[void](self)

template await*(self: Event) =
    ## if called after trigger, ensure all preceding waiters have complete
    await self.wait()

proc trigger*(self: Event) =
    if not Future[void](self).finished:
        Future[void](self).complete()

proc isTriggered*(self: Event): bool =
    Future[void](self).finished

proc clear*(self: Event) =
    if Future[void](self).finished:
        Future[void](self).clean()

converter toFut*(self: Event): Future[void] =
    self.wait()

converter toBool*(self: Event): bool =
    Future[void](self).finished