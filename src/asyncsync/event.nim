import std/[asyncdispatch]
import std/importutils


privateAccess(FutureBase)


type
    Event* = ref object
        fut: Future[void]
        ## Waiters wakening can be unordered (According to asyncdispatch doc: in the order of await macro call)
        ## For ordered events, cleaner method is to use in combination with a lock


template await*(self: Event) =
    ## if called after trigger, ensure all preceding waiters have complete
    await self.fut()

proc clean*[T](fut: Future[T]) =
    fut.finished = false
    fut.error = nil

proc clear*(self: Event) =
    ## Clear guaranties that all waiters will be triggered, but no that have all waiters are already triggered
    ## To be sure that all waiters will be triggered, await the event yourself, and you will be the last one
    self.fut = newFuture[void]()

proc consume*(self: Event) =
    ## Waiters after this call will be triggered.
    ## However it should be called immediatly without using another await (or then), or waiters will certainly will be all triggered
    if self.fut.finished:
        self.fut.clean()

proc new*(T: type Event): T =
    T(fut: newFuture[void]())

proc trigger*(self: Event) =
    if not self.fut.finished:
        self.fut.complete()

proc triggered*(self: Event): bool =
    self.fut.finished

converter toBool*(self: Event): bool =
    self.fut.finished

converter toFut*(self: Event): Future[void] =
    self.fut
