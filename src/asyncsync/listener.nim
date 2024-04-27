import std/[asyncdispatch]
import ./event

type Listener* = ref object
    ## An event triggered when a future complete
    ev: Event
    isListening: bool


proc new*(T: type Listener): T
proc wait*(self: Listener): Future[void]
proc isTriggered*(self: Listener): bool
proc clear*(self: Listener)
proc listen*(self: Listener): Future[void]
proc listen*(self: Listener, fut: Future[void])
proc isListening*(self: Listener): bool
converter toFut*(self: Listener): Future[void]
converter toBool*(self: Listener): bool

proc new*(T: type Listener): T =
    T(ev: Event.new())

proc wait*(self: Listener): Future[void] =
    self.ev.wait()

proc trigger*(self: Listener) =
    self.ev.trigger()
    self.isListening = false

proc isTriggered*(self: Listener): bool =
    self.ev.isTriggered()

proc clear*(self: Listener) =
    self.ev.clear()

proc listen*(self: Listener): Future[void] =
    # Can't listen without creating a future
    result = newFuture[void]("Listener")
    self.listen(result)

proc listen*(self: Listener, fut: Future[void]) =
    if self.isListening or self.isTriggered:
        raise newException(IOError, "Can't listen if already listening or triggered")
    self.isListening = true
    fut.addCallback(proc() {.closure.} =
        self.trigger()
    )

proc isListening*(self: Listener): bool =
    self.isListening

converter toFut*(self: Listener): Future[void] =
    self.ev.wait()

converter toBool*(self: Listener): bool =
    self.ev.isTriggered