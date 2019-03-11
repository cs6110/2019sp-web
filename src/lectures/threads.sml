open SMLofNJ.Cont
open Queue

type thread = unit cont

val ready : thread queue = mkQueue () (* a mutable FIFO queue *)
fun enq t = enqueue (ready, t)
fun dispatch() = throw (dequeue ready) ()
fun spawn (f : unit -> unit) : unit =
 callcc (fn k => (enq k; f(); dispatch()))
fun yield() : unit = callcc (fn k => enq k; dispatch())
