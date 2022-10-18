# Chapter 09 - Isolating Errors

A supervisor can provide error detection and recovery. It can also isolate error effects from crashed processes. With this way, the whole system still can provide at least partial service to the clients.

We can introduce a **Registry** for storing the worker process name. Later when a client to a worker, it can lookup the registry first for the PID and then send the request.
