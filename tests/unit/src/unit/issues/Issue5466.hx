package unit.issues;

class Issue5466 extends Test {
  function test() {
    var test:Base = (Math.random() > 0.5) ? new A() : new B();
    t(Std.is(test, A) || Std.is(test, B));
  }
}

private class Base {
  public function new() {}
}

private class A extends Base {
}
private class B extends Base {
}
