import std/[asyncdispatch]
import std/importutils


privateAccess(FutureBase)


type
    Event* = distinct Future[void]
        ## Waiters wakening can be unordered (According to asyncdispatch doc: in the order of await macro call)
        ## For ordered events, cleaner method is to use in combination with a lock


proc clean*[T](fut: Future[T])

converter toBool*(self: Event): bool
converter toFut*(self: Event): Future[void]
proc clear*(self: Event)
proc new*(T: type Event): T
proc trigger*(self: Event)
proc triggered*(self: Event): bool
proc wait*(self: Event): Future[void]


template await*(self: Event) =
    ## if called after trigger, ensure all preceding waiters have complete
    await self.wait()

proc clean*[T](fut: Future[T]) =
    fut.finished = false
    fut.error = nil


converter toBool*(self: Event): bool =
    Future[void](self).finished

converter toFut*(self: Event): Future[void] =
    self.wait()

proc clear*(self: Event) =
    if Future[void](self).finished:
        Future[void](self).clean()

proc new*(T: type Event): T =
    T(newFuture[void]("Event"))

proc trigger*(self: Event) =
    if not Future[void](self).finished:
        Future[void](self).complete()

proc triggered*(self: Event): bool =
    Future[void](self).finished

proc wait*(self: Event): Future[void] =
    Future[void](self)
