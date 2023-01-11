The mem_monitor module monitors axi4 transactions and determines contention between the different initiators of transactions. The initiators of transactions are given by a world ID encoded in the QoS field of the AXI channels.
The mem_monitor module supports the following contention tracking features:
- Read contention monitoring backpressure channels
- Read contention blaming the head of the queue for all contention caused in the queue
- Cross Read-Write backpressure. If the read channel is getting backpressure from the slave, but no read requests are pending, then we blame this backpressure contention on the head of the write channel queue.
- Write backpressure monitoring.
- Cross Write-Read backpressure. See cross read-write backpressure.
