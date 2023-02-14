import typescript from "@rollup/plugin-typescript";

import pkg from "./package.json" assert { type: "json" };

export default {
  input: pkg.source,
  output: {
    format: "cjs",
    file: pkg.main,
  },
  plugins: [typescript({ declaration: true, outDir: pkg.main })],
};
