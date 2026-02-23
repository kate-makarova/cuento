# ADR 004: Event Bus

The backend of Cuento leverages event bus and asynchronous handlers. Things that do not 
need to happen in the same transaction as the main action, are processed in 
asynchronous handlers - subscribers. There are several reasons for that:

1. The code becomes cleaner. It creates a natural separating of concerns, and 
controllers do not become overblown.
2. Mitigating potential bottlenecks. For example, updating a total post counter can 
create a potential race condition, and the controller will not be able to finish
until it gets its turn to write to a frequently updated row. Now this action is performed
asynchronously and does not block the main flow.
3. Leveraging Go's natural love for concurrency. Go is famous for its lightweight
threads, so moving part of the job into an asynchronous subprocess adds effectiveness.
4. Websocket notifications. The EventBus is natively integrated with WebsocketHub,
which allows to send live notifications to users. 