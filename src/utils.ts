import { exec } from "child_process";
import { promisify } from "util";

export const execAsync = (command: string) => 
  promisify(exec)(command, { encoding: "utf8" })
    .then((result) => result.stdout.trim());