import std/[asyncdispatch]

import ./lock {.all.}

type Semaphore* = ref object of Lock
    ## Child of Lock
    counter: int
    lock: LockImpl


method acquire*(self: Semaphore) {.async.} =
    if self.counter == 0:
        await self.lock.acquire()
    self.counter -= 1

method locked*(self: Semaphore): bool =
    self.lock.locked()

proc new*(T: type Semaphore, value: int): T =
    T(counter: value, lock: LockImpl.new())

method release*(self: Semaphore) =
    if self.counter == 0:
        self.lock.release()
    self.counter += 1
