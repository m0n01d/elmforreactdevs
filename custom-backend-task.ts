import { readdir } from "node:fs/promises";
import * as path from "path";

export async function hello(name) {
  return `Hello ${name}!`;
}

export async function blogPosts() {
  const dir = path.join("posts");
  console.log(dir);
  const files = await readdir(dir);

  console.log({ XXXFILES: files });
  return await files;
}
