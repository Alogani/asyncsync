import ./event
import std/[asyncdispatch]

type Listener* = ref object
    ## An event triggered when a future complete
    event: Event
    listening: bool


converter toBool*(self: Listener): bool
converter toFut*(self: Listener): Future[void]
proc clear*(self: Listener)
proc listen*(self: Listener): Future[void]
proc listen*(self: Listener, fut: Future[void])
proc listening*(self: Listener): bool
proc new*(T: type Listener): T
proc trigger*(self: Listener) {.gcsafe.}
proc triggered*(self: Listener): bool
proc wait*(self: Listener): Future[void]

converter toBool*(self: Listener): bool =
    self.event.triggered

converter toFut*(self: Listener): Future[void] =
    self.event.wait()

proc clear*(self: Listener) =
    self.event.clear()

proc listen*(self: Listener): Future[void] =
    # Can't listen without creating a future
    result = newFuture[void]("Listener")
    self.listen(result)

proc listen*(self: Listener, fut: Future[void]) =
    if self.listening or self.triggered:
        raise newException(IOError, "Can't listen if already listening or triggered")
    self.listening = true
    fut.addCallback(proc() {.closure.} =
        self.trigger()
    )

proc listening*(self: Listener): bool =
    self.listening

proc new*(T: type Listener): T =
    T(event: Event.new())

proc trigger*(self: Listener) =
    self.event.trigger()
    self.listening = false

proc triggered*(self: Listener): bool =
    self.event.triggered()

proc wait*(self: Listener): Future[void] =
    self.event.wait()
