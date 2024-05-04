import ./event
import std/[asyncdispatch]

type Listener* = ref object
    ## An event triggered when a future complete
    event: Event
    listening: bool


proc clear*(self: Listener) =
    self.event.clear()

proc trigger*(self: Listener) =
    self.event.trigger()
    self.listening = false

proc triggered*(self: Listener): bool =
    self.event.triggered()

proc listen*(self: Listener, fut: Future[void]) =
    if self.listening or self.triggered:
        raise newException(IOError, "Can't listen if already listening or triggered")
    self.listening = true
    fut.addCallback(proc() {.closure.} =
        self.trigger()
    )

proc listen*(self: Listener): Future[void] =
    # Can't listen without creating a future
    result = newFuture[void]("Listener")
    self.listen(result)

proc listening*(self: Listener): bool =
    self.listening

proc new*(T: type Listener): T =
    T(event: Event.new())



proc wait*(self: Listener): Future[void] =
    self.event.wait()

converter toBool*(self: Listener): bool =
    self.event.triggered

converter toFut*(self: Listener): Future[void] =
    self.event.wait()