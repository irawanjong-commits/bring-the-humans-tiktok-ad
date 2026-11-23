// bring-the-humans-03 entry program (Node 22, standard library only).
//
// The entry itself is the TikTok video named by VIDEO.json; this program's
// only job is to hand that file to the grader: it copies VIDEO.json from
// the repository root (MAKEFUN_BOT_DIR, or /bot in the grader) into the
// output directory (MAKEFUN_OUTPUT_DIR, or /output), creating the output
// directory first. It prints nothing on success and exits 1 with a clear
// error when VIDEO.json is missing, so a broken entry fails loudly.
//
// Run it the way the grader does:
//   mkdir -p out && MAKEFUN_BOT_DIR=. MAKEFUN_OUTPUT_DIR=out node main.ts

import { copyFileSync, existsSync, mkdirSync } from "node:fs";
import { join } from "node:path";

const botDir = process.env.MAKEFUN_BOT_DIR ?? "/bot";
const outputDir = process.env.MAKEFUN_OUTPUT_DIR ?? "/output";

mkdirSync(outputDir, { recursive: true });

const source = join(botDir, "VIDEO.json");
const target = join(outputDir, "VIDEO.json");

if (!existsSync(source)) {
  console.error(`main.ts: VIDEO.json is missing from the repository at ${source}`);
  process.exit(1);
}

try {
  copyFileSync(source, target);
} catch (err) {
  console.error(
    `main.ts: could not copy VIDEO.json from ${source} to ${target}: ${(err as Error).message}`,
  );
  process.exit(1);
}
