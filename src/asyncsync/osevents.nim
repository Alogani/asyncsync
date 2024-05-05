## Wrappers to convert addRead, addWrite, addProcess, etc. to futures
import ./event
import std/asyncdispatch

type
    ProcessEvent* = ref object
        ## When a process exit
        pid: int
        event: Event

    ReadEvent* = ref object
        ## When read data is available
        fd: AsyncFd
        event: Event

    WriteEvent* = ref object
        ## When writing is available
        fd: AsyncFd
        event: Event

proc new*(T: type ProcessEvent, pid: int): T =
    ProcessEvent(pid: pid)

proc new*(T: type ReadEvent, fd: int): T =
    ## The fd must have been registered in the dispatcher first
    ReadEvent(fd: fd.AsyncFd)

proc new*(T: type WriteEvent, fd: int): T =
    ## The fd must have been registered in the dispatcher first
    WriteEvent(fd: fd.AsyncFd)

proc getFuture*(self: ProcessEvent): Future[void] =
    ## The callback is not called multiple times if not needed
    if self.event == nil:
        self.event = Event.new()
        addProcess(self.pid, proc(_: AsyncFD): bool {.closure, gcsafe.} =
            self.event.trigger()
            self.event = Event(nil)
            return true
        )
    return self.event

proc getFuture*(self: ReadEvent): Future[void] =
    ## The callback is not called multiple times if not needed
    if self.event == nil:
        self.event = Event.new()
        addRead(self.fd, proc(_: AsyncFD): bool {.closure, gcsafe.} =
            self.event.trigger()
            self.event = Event(nil)
            return true
        )
    return self.event

proc getFuture*(self: WriteEvent): Future[void] =
    ## The callback is not called multiple times if not needed
    if self.event == nil:
        self.event = Event.new()
        addWrite(self.fd, proc(_: AsyncFD): bool {.closure, gcsafe.} =
            self.event.trigger()
            self.event = Event(nil)
            return true
        )
    return self.event
