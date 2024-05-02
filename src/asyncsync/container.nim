import std/[asyncdispatch]

import ./lock

type Container*[T] = ref object
    ## A resource associated with a lock
    lock: Lock
    resource: T


template with*[T](self: Container[T], resource: out T, body: untyped): untyped =
    with self.lock:
        resource = self.resource
        body


proc new*[T](O: type Container[T], resource: T, lock: Lock = Lock.new()): O =
    O[T](resource: resource, lock: lock)

proc acquire*[T](self: Container[T]): Future[T] {.async.} =
    await self.lock.acquire()
    self.resource

proc locked*[T](self: Container[T]): bool =
    self.lock.locked()

proc release*[T](self: Container[T]) =
    self.lock.release()
