import { cpSync, mkdirSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const dest = join(root, "dist", "phpmailer");

mkdirSync(dest, { recursive: true });
cpSync(join(root, "phpmailer", "src"), dest, { recursive: true });
writeFileSync(join(dest, ".htaccess"), "Require all denied\n");
