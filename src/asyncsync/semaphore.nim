import std/[asyncdispatch]

import ./lock {.all.}

type Semaphore* = ref object of Lock
    ## Child of Lock
    lock: LockImpl
    counter: int

proc new*(T: type Semaphore, value: int): T
method acquire*(self: Semaphore): Future[void]
method release*(self: Semaphore) {.gcsafe.}
method isLocked*(self: Semaphore): bool

proc new*(T: type Semaphore, value: int): T =
    T(counter: value, lock: LockImpl.new())

method acquire*(self: Semaphore) {.async.} =
    if self.counter == 0:
        await self.lock.acquire()
    self.counter -= 1

method release*(self: Semaphore) =
    if self.counter == 0:
        self.lock.release()
    self.counter += 1

method isLocked*(self: Semaphore): bool =
    self.lock.isLocked()