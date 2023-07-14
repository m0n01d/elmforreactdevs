import { readdir, readFile } from "node:fs/promises";
import * as path from "path";

export async function hello(name) {
  return `Hello ${name}!`;
}

export async function blogPosts() {
  const dir = path.join("posts");
  const files = await readdir(dir);

  return files;
}
