# Asyncsync

Asynchronous primitives working on std/asyncdispatch

## Features

- Non blocking: most operations can be cancelled using any future (like a timer)
- Easy integration with any function that excepts a Future[void]

### Examples of objects defined :
- Lock (and lock addition)
- Semaphore
- Event (a Future that can be triggered and cleared)
- Listener (an Event that will be triggered when another Event complete)
- Container

### Completes std/asyncfutures

Implements :
- `proc any*(l: varargs[Future[void]]): Future[void]`
- then

## Getting started

### Installation
`nimble install asyncsync`

### Example usage

```
import asyncsync, asyncsync/[lock, event]

proc echoDelay(data: string, delaySecs: int) {.async.} =
  await sleepAsync(delaySecs * 1000)
  echo(data)

proc main(): Future[void] {.async.} =
  var lock = Lock.new()
  var event = Event.new()

  ## Will be called only when Event complete
  result = event.then(proc() = echo "Finished")

  ## Print in order of call
  for i in 0..2:
    withLock lock:
      echoDelay("Idx=" & $i, (3 - i))

  event.trigger()
  await event ## Ensure all events are consumed
  event.clear()

  echo event.isTriggered == false
    

waitFor main()

```

### To go further
Please see source code for each object you need to see its API

## Before using it
- Unstable API : How you use asyncsync is susceptible to change. It could occur to serve [asyncproc](https://github.com/Alogani/asyncproc) or [asyncio](https://github.com/Alogani/asyncio) library development. _v1.0.0 is programmed to be released as soon as possible_ 
- Only support one async backend: std/asyncdispatch (_This project is *not* related to [chronos/asyncsync](https://github.com/status-im/nim-chronos/blob/master/chronos/asyncsync.nim)_)
