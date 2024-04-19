import std/[asyncdispatch]
import ./lock

type
    LockList = ref object of Lock
        ## High chance of deadlocks if you mess up
        locks: seq[Lock]
        locked: bool

proc merge*(locks: varargs[Lock]): LockList
proc `and`*(a, b: Lock): LockList
method acquire*(self: LockList): Future[void]
method release*(self: LockList) {.gcsafe.}
method isLocked*(self: LockList): bool


proc merge*(locks: varargs[Lock]): LockList =
    LockList(locks: @locks)

proc `and`*(a, b: Lock): LockList =
    merge(a, b)

method acquire*(self: LockList): Future[void] =
    self.locked = true
    var allFuts = newSeqOfCap[Future[void]](self.locks.len())
    for l in self.locks:
        allFuts.add(l.acquire())
    result = all(allFuts)

method release*(self: LockList) {.gcsafe.} =
    for l in self.locks:
        l.release()
    self.locked = false

method isLocked*(self: LockList): bool =
    self.locked
