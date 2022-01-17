import * as E from "./dce-output/Eval/index.js";
var foo = E.recordUpdate({ foo: "", bar: 0 })(E.Foo.create("foo"));
if (foo.foo != "foo") {
  console.error(foo);
  throw "Error";
}
