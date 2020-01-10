type ApplicationService* = ref object of RootObj

proc fib*(this: ApplicationService, n: int): int =
  if n < 2:
    return n
  return this.fib(n - 2) + this.fib(n - 1)
