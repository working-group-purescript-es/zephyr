import { span } from "./dce-output/Data.Array/index.js";

const res = span((n) => n % 2 == 1)([1, 3, 2, 4, 5]);
if (res.init.includes(2) || res.init.includes(4) || res.init.includes(5)) {
  throw "Error";
}
